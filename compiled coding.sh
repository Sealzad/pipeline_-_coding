

#trimmomatic

java -jar trimmomatic-0.36.jar PE -phred33 ~/input/5890_1.fq.gz ~/input/5890_2.fq.gz ~/output/5890_trimmed1_P.fq ~/output/5890_trimmed1_UP.fq ~/output/5890_trimmed2_P.fq ~/output/5890_trimmed2_UP.fq LEADING:15 TRAILING:20 HEADCROP:15 SLIDINGWINDOW:4:15 MINLEN:70 |tee -a ~/track_log_20180325


#BWA aligner

bwa mem -t 20 ~/genome_data/GRCh38/sequence/Homo_sapiens.GRCh38.dna.primary_assembly.fa ~/input/RHM5887_PE_1.fq  ~/input/RHM5887_PE_2.fq > ~/output/bwa_output/RHM5887_PE.sam


#CIRI (must be aligned with BWA men first)

perl CIRI2.pl -I ~/output/bwa_output/RHM5890_PE.sam -O ~/output/CIRI_output/RHM5890_circRNA -F ~/genome_data/GRCh38/sequence/Homo_sapiens.GRCh38.dna.primary_assembly.fa


#Sailfish-cir

python sailfish_cir.py -g ~/genome_data/GRCh38/sequence/Homo_sapiens.GRCh38.dna.primary_assembly.fa -a ~/genome_data/GRCh38/annotation/Homo_sapiens.GRCh38.91.gtf -1 ~/input/RHM5886_PE_1.fq -2 ~/input/RHM5886_PE_2.fq -o ~/output/sailfish-cir_output/RHM5886 -c ~/output/CIRI_output/RHM5886_circRNA


#map splice

Use the trimmed paired fasta files. I.e., the fasta files must be unzipped.

python mapsplice.py -x ~/mapsplice_database/GRCh38_no_alt_BT/ -1 ~/input/RHM5886_PE_1.fq -2 ~/input/RHM5886_PE_2.fq --fusion-non-canonical -p 30 --qual-scale phred33 --bam --gene-gtf ~/mapsplice_database/Homo_sapiens.GRCh38.91.gtf --min-fusion-distance 200 -o ~/mapsplice_output/RHM5886 -c ~/mapsplice_database/GRCh38_genome/


#qualimap

./qualimap rnaseq -bam ~/output/RHM5890.bam -gtf ~/genome_data/GRCh37/annotation/Homo_sapiens_GRCh37_gencode.gtf -oc ~/output/RHM5890counts --paired --java-mem-size=100G | tee -a ~/track_log_201803013



#Samtools Mpileup (you need to wait for one process to be done before you execute the next. For some reason, the system cannot segregate the two processes.

samtools mpileup  -v -f ~/genome_data/GRCh37/sequence/GRCh37.primary_assembly.genome.fa ~/input/CNTMYC_1_sorted.bam -o ~/input/file.vcf.gz

zcat file.vcf.gz | bgzip -c > file.new.vcf.gz && tabix file.new.vcf.gz

bcftools consensus -i -f ~/genome_data/GRCh37/sequence/GRCh37.primary_assembly.genome.fa ~/input/file.vcf.gz >  ~/input/test.fa


#Different coding

samtools mpileup -vf  ~/genome_data/GRCh37/sequence/GRCh37.primary_assembly.genome.fa ~/input/CNTMYC_1_sorted.bam | bcftools call -m -O z - > test.vcf.gz && tabix test.vcf.gz

bcftools index test.vcf.gz

bcftools consensus -f ~/genome_data/GRCh37/sequence/GRCh37.primary.assembly.fq.gz test.vcf.gz -o ~/input/consensus.fa


#ORF_finder

You must download and install the Biopython tool kits inside the system first. Make sure pip, python and make are available for use. Then copy over the ORF_finder script, remove the bugs that cause the script to crash. Then run it.
 python biopython_orf_find_a.py -i /Volumes/My\ Book/splicing/207_L7_consensus.fa -o ~/207_L7.fa -num 5 -st both

#TopHat

./tophat ~/mapsplice_database/GRCh38_no_alt_BT/ ~/input/209_1.fq.gz ~/input/209_2.fq.gz --bowtie1 -o ~/mapsplice_output/ -p 30 --GTF ~/mapsplice_database/Homo_sapiens.GRCh38.91.gtf


#Cufflink (extract transcripts)

.sam files must be sorted for cufflinks to work

sort -k 3,3 -k 4,4n hits.sam > hits.sam.sorted

cufflinks [options] <aligned_reads.(sam/bam)>

http://seqanswers.com/forums/archive/index.php/t-5116.html
gffread -w transcripts.fa -g /path/to/genome.fa transcripts.gtf



#BamToBed from Bedtools

bedtools bamtobed -i /Volumes/My\ Book/splicing/207_L7_sorted.bam
