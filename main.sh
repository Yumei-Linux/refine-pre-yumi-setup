#!/usr/bin/env bash

if [ ! -d /sources ]; then
    echo "[Fatal] /sources no such file or directory."
    exit 1
fi

while [ ! -f /sources/wget-1.21.4.tar.gz ]; do
    echo "refine-pre-yumi-setup: This script requires you to download https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz in /sources/wget-1.21.4.tar.gz"
    printf "Please download it from the host system before continuing... "
    read
done

pushd /sources

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
make MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.0.8
cp -vfr doc/* /usr/share/doc/openssl-3.0.8

cd ../
tar -xvf ./pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2

./configure --prefix=/usr \
    --with-internal-glib \
    --disable-host-tool \
    --docdir=/usr/share/doc/pkg-config-0.29.2

make && make install

cd ../
tar -xvf ./wget-1.21.4.tar.gz
cd ./wget-1.21.4

./configure --prefix=/usr \
    --sysconfdir=/etc \
    --with-ssl=openssl

make && make install

cd ../

echo "[I] Remember to configure the /etc/resolv.conf in order to let yumi resolve dns"
echo "  * Here is an example on how to use the google's dns"
echo "  * $ echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
printf "Do it from another terminal and when done press enter to continue... "
read

while [ ! -f /usr/bin/yumi ]; do
    echo "refine-pre-yumi-setup: Cannot find a yumi installation, please build it from the host system and put it at /usr/bin to continue"
    printf "Press enter to try to continue... "
    read
done

while [ ! -d /var/yumi ]; do
    echo "refine-pre-yumi-setup: Cannot find an initial yumi database, please clone it at /var/yumi to continue"
    echo "$ git clone https://github.com/yumei-linux/yumi-packages.git /mnt/var/yumi (in the host system)"
    printf "Press enter to try to continue... "
    read
done

/usr/bin/yumi grab security/ca-certificates

popd
