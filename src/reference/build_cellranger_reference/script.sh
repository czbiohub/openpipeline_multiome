#!/bin/bash

## VIASH START
par_genome_fasta="resources_test/bdrhap_ref_gencodev41_chr1/reference_gencode_v41_chr1.fa.gz"
par_transcriptome_gtf="resources_test/bdrhap_ref_gencodev41_chr1/reference_gencode_v41_chr1.gtf.gz"
par_output="resources_test/bdrhap_ref_gencodev41_chr1/gencode_v41_annotation_cellranger.tar.gz"
## VIASH END

# create temporary directory
tmpdir=$(mktemp -d "$VIASH_TEMP/$meta_resources_name-XXXXXXXX")
function clean_up {
    rm -rf "$tmpdir"
}
trap clean_up EXIT

# just to make sure
par_genome_fasta=`realpath $par_genome_fasta`
par_transcriptome_gtf=`realpath $par_transcriptome_gtf`
par_output=`realpath $par_output`

# process params
extra_params=( )

if [ ! -z "$meta_n_proc" ]; then 
  extra_params+=( "--nthreads=$meta_n_proc" )
fi
if [ ! -z "$meta_memory_gb" ]; then 
  # always keep 2gb for the OS itself
  memory_gb=`python -c "print(int('$meta_memory_gb') - 2)"`
  extra_params+=( "--memgb=$memory_gb" )
fi

echo "> Unzipping input files"
unpigz -c "$par_genome_fasta" > "$tmpdir/genome.fa"

echo "> Building star index"
cd "$tmpdir"
cellranger mkref \
  --fasta "$tmpdir/genome.fa" \
  --genes "$par_transcriptome_gtf" \
  --genome output \
  "${extra_params[@]}"

echo "> Creating archive"
tar --use-compress-program="pigz -k " -cf "$par_output" -C "$tmpdir/output" .