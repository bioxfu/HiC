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

# install LACHESIS
# build boost (using Python2)
wget https://nchc.dl.sourceforge.net/project/boost/boost/1.52.0/boost_1_52_0.tar.bz2
tar jxf boost_1_52_0.tar.bz2
cd boost_1_52_0
./bootstrap.sh --prefix=$HOME/opt/boost
./b2
./b2 install
cd ..
# build samtools
wget https://nchc.dl.sourceforge.net/project/samtools/samtools/0.1.18/samtools-0.1.18.tar.bz2
tar xjf samtools-0.1.18.tar.bz2
cd samtools-0.1.18
make 
mkdir bam
cp sam.h bam
cd ..
# build LACHESIS
git clone https://github.com/shendurelab/LACHESIS
cd LACHESIS
./configure --with-samtools=$PWD/../samtools-0.1.18/ --with-boost=/cluster/home/xfu/opt/boost
# edit line 279 of src/include/gtools/Makefile to add samtools path and boost path
# edit line 283 of src/include/markov/Makefile to add samtools path and boost path
# for example: INCLUDES = -I/cluster/home/xfu/Project/Gossypium_trilobum/canu/HiC/samtools-0.1.18/ -I/cluster/home/xfu/opt/boost/include
# edit line 287 of src/include/markov/Makefile to add library path
# for example: BOOST_LIBS = -lboost_system -lboost_filesystem -lboost_regex -L/cluster/home/xfu/opt/boost/lib 
make 
cp Lachesis bin

# Aligning the Hi-C reads to the draft assembly
nohup bash -c "bwa mem -t 30 draft/draft.fa fastq/mianhua_clean_R1.fastq.gz fastq/mianhua_clean_R2.fastq.gz|samtools view -bS - > bwa_out/mianhua.bam" &
# Filtering the Hi-C reads
script/PreprocessSAMs.pl bwa_out/mianhua.bam draft/draft.fa
#Running LACHESIS
cp example/Lachesis.ini Lachesis.ini
export PATH=$PWD/LACHESIS/src/bin:$PATH
Lachesis Lachesis.ini
script/CreateScaffoldedFasta.pl draft/draft.fa Lachesis_out

