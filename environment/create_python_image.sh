cntr=$(buildah from python:3-alpine)
mnt=$(buildah mount $cntr)

buildah config --env CFLAGS="-g0 -Os" $cntr
buildah run $cntr apk add --update --no-cache python-dev gfortran py-pip build-base gcc freetds-dev snappy-dev
buildah run $cntr pip install --user --compile --no-cache-dir --global-option=build_ext Cython
buildah run $cntr pip install --user --compile --no-cache-dir --global-option=build_ext numpy
buildah run $cntr pip install --user --compile --no-cache-dir --global-option=build_ext pymssql spavro networkx parquet pandas

buildah run $cntr apk add --no-cache \
            git \
            build-base \
            cmake \
            bash \
            talloc \
            boost-dev \
            autoconf \
            zlib-dev \
            flex \
            bison
buildah run $cntr git clone https://github.com/apache/arrow.git
buildah run $cntr mkdir /arrow/cpp/build
buildah config --workingdir /arrow/cpp/build $cntr
buildah config --env PARQUET_HOME=/usr/local $cntr
buildah run $cntr sed -i -e '/_EXECINFO_H/,/endif/d' -e '/execinfo/d' ../src/arrow/util/logging.cc
buildah run $cntr cmake -DCMAKE_BUILD_TYPE=release \
          -DCMAKE_INSTALL_LIBDIR=lib \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DARROW_PARQUET=on \
          -DARROW_PYTHON=on \
          -DARROW_PLASMA=on \
          -DARROW_BUILD_TESTS=OFF \
          ..
buildah run $cntr make -j$(nproc)
buildah run $cntr make install
buildah config --workingdir /arrow/python $cntr
buildah run $cntr python setup.py build_ext --build-type=release \
       --with-parquet --inplace --user
buildah run $cntr python setup.py install --user

cntr2=$(buildah from python:3-alpine)
mnt2=$(buildah mount $cntr2)

cp -r $mnt/root/.local $mnt2/root/
cp -P $mnt/usr/lib/libstdc++.so* $mnt2/usr/lib/
cp -P $mnt/usr/lib/libgcc_s.so* $mnt2/usr/lib/
cp -P $mnt/usr/lib/libsybdb.so* $mnt2/usr/lib/
cp -P $mnt/usr/lib/libboost_filesystem.so* $mnt2/usr/lib/
cp -P $mnt/usr/lib/libsnappy.so* $mnt2/usr/lib/
cp -R $mnt/arrow/cpp/build/release/. $mnt2/root/.local/lib/
buildah config --env LD_LIBRARY_PATH=/root/.local/lib $cntr2


buildah commit --format=docker $cntr2 my-python-image
buildah unmount $cntr
buildah unmount $cntr2
buildah rm $cntr2 $cntr
