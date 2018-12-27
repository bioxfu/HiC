source activate gmatic

# install Jucier and 3D-DNA
git clone https://github.com/aidenlab/juicer
git clone https://github.com/theaidenlab/3d-dna

# remove the adaptor sequence from reads using raw data given by Novogene
mkdir fastq
python script/rm_adapter.py raw/mianhua_1.adapter.list.gz raw/mianhua_1.fq.gz fastq/mianhua_clean_R1.fastq.gz
python script/rm_adapter.py raw/mianhua_2.adapter.list.gz raw/mianhua_2.fq.gz fastq/mianhua_clean_R2.fastq.gz

# index the draft fastq sequence using BWA
mkdir draft
cp /cluster/home/xfu/Project/Gossypium_trilobum/canu/pilon_nucl/asm/Gossypium_trilobum_nucl.round4.fasta draft/draft.fa
bwa index draft/draft.fa
samtools faidx draft/draft.fa
cut -f1,2 draft/draft.fa.fai > draft/draft_chrom_sizes

# generate a restrictin sites file for draft fasta (python2)
~/miniconda2/bin/python juicer/misc/generate_site_positions.py DpnII draft draft/draft.fa

# run juicer
# Display queue/partition names, runtimes and available nodesqstat -q
#PBS
#qstat -q
#SLURM
#sinfo
juicer/SLURM/scripts/juicer.sh -g draft -d $PWD -s DpnII -z draft/draft.fa -y draft_DpnII.txt -p draft/draft_chrom_sizes -q fat -l fat -D $PWD/juicer/SLURM

# run 3D-DNA
mkdir scaf
cd scaf
nohup ../3d-dna/run-asm-pipeline.sh ../draft/draft.fa ../aligned/merged_nodups.txt &

