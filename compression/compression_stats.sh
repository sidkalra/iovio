
cntr=$(buildah from alpine)
mnt=$(buildah mount $cntr)
fname=file.txt

workingdir=$mnt/usr/test-compression

buildah run $cntr mkdir -p /usr/test-compression
buildah config --workingdir /usr/test-compression $cntr

buildah run $cntr apk add --update zip p7zip lzip gzip zstd curl

txt_url=http://mattmahoney.net/dc/enwik8.zip
echo Downloading sample text file from $txt_url
buildah run $cntr curl -o enwik8.zip $txt_url
#cp /root/enwik8.zip $workingdir/

echo unzipping downloaded file...
buildah run $cntr sh -c "unzip -p enwik8.zip > $fname"

txt_filesize=$(du -b $workingdir/$fname | cut -f1)

echo Compressing using zip...
zip_t1=$(date +%s)
buildah run $cntr zip $fname.zip $fname
zip_t2=$(date +%s)
zip_filesize=$(du -b $workingdir/$fname.zip | cut -f1)

echo Compressing using 7z...
p7z_t1=$(date +%s)
buildah run $cntr 7z a $fname.7z $fname
p7z_t2=$(date +%s)
p7z_filesize=$(du -b $workingdir/$fname.7z | cut -f1)

echo Compressing using lz...
lz_t1=$(date +%s)
buildah run $cntr lzip -k -f $fname
lz_t2=$(date +%s)
lz_filesize=$(du -b $workingdir/$fname.lz | cut -f1)

echo Compressing using gz...
gz_t1=$(date +%s)
buildah run $cntr gzip -k -f $fname
gz_t2=$(date +%s)
gz_filesize=$(du -b $workingdir/$fname.gz | cut -f1)

echo Compressing using zstd...
zst_t1=$(date +%s)
buildah run $cntr zstd -k -f $fname
zst_t2=$(date +%s)
zst_filesize=$(du -b $workingdir/$fname.zst | cut -f1)

min_time=10000 #arbitarily large number
best_compression=$txt_filesize
best_cmp_type=zip
min_time_type=zip
print_details()
{
	echo 
	echo +++++++++++ $1 compression - $2 ++++++++++
	echo compressed file size: $(($3/1048576))MB
	echo compression ratio: "$(($3*100/$txt_filesize))"%
	echo time taken: $(($4-$5)) seconds
	if [ $3 -lt $best_compression ]
	then
	best_cmp_type=$1
	best_compression=$3
	fi
	if [ $(($4-$5)) -lt $min_time ]
	then
	min_time_type=$1
	min_time=$(($4-$5))
	fi
}

echo ======= COMPRESSION STATS =======
echo original file size: $(($txt_filesize/1048576))MB
print_details zip $fname.zip $zip_filesize $zip_t2 $zip_t1
print_details 7z $fname.7z $p7z_filesize $p7z_t2 $p7z_t1
print_details lz $fname.lz $lz_filesize $lz_t2 $lz_t1
print_details gz $fname.gz $gz_filesize $gz_t2 $gz_t1
print_details zstd $fname.zst $zst_filesize $zst_t2 $zst_t1

echo
echo Best compression algorithm: $best_cmp_type --- compressed to "$(($best_compression*100/$txt_filesize))"%
echo Minimum time taken by: $min_time_type --- compressed in $min_time seconds

buildah unmount $cntr > /dev/null
buildah rm $cntr > /dev/null

