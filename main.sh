#!/usr/bin/env bash

if [ ! -d /sources ]; then
    echo "[Fatal] /sources no such file or directory."
    exit 1
fi

push /sources

tar -xvf ./zlib-1.2.13.tar.xz
cd zlib-1.2.13

./configure --prefix=/usr
make && make install
rm -fv /usr/lib/libz.a

cd ../
tar -xvf ./bzip2-1.0.8.tar.gz
cd bzip2-1.0.8

patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch

sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

make -f Makefile-libbz2_so
make clean
make
make PREFIX=/usr install

cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat

cd ../
tar -xvf ./perl-5.36.0.tar.xz
cd perl-5.36.0

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des \
    -Dprefix=/usr \
    -Dvendorprefix=/usr \
    -Dprivlib=/usr/lib/perl5/5.36/core_perl \
    -Darchlib=/usr/lib/perl5/5.36/core_perl \
    -Dsitelib=/usr/lib/perl5/5.36/site_perl \
    -Dvendorlib=/usr/lib/perl5/5.36/vendor_perl \
    -Dvendorarch=/usr/lib/perl5/5.36/vendor_perl \
    -Dmanldir=/usr/share/man/man1 \
    -Dman3dir=/usr/share/man/man3 \
    -Dpager="/usr/bin/less -isR" \
    -Duseshrplib \
    -Dusethreads

make && make install

unset BUILD_ZLIB BUILD_BZIP2

cd ../
tar -xvf ./openssl-3.0.8.tar.gz
cd openssl-3.0.8

./config --prefix=/usr \
    --openssldir=/etc/ssl \
    --libdir=lib \
    shared \
    zlib-dynamic

make
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl isntall

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.0.8
cp -vfr doc/* /usr/share/doc/openssl-3.0.8

echo "[I] Remember to configure the /etc/resolv.conf in order to let yumi resolve dns"
echo "  * Here is an example on how to use the google's dns"
echo "  * $ echo 'nameserver 8.8.8.8' > /etc/resolv.conf"

popd