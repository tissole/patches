set -e
FullExecPath=$PWD
pushd `dirname $0` > /dev/null
FullScriptPath=`pwd`
popd > /dev/null

# Add x86_64-win64-vs18 to configure's platform list (before vs17)
sed -i '/x86_64-win64-vs17/i all_platforms="${all_platforms} x86_64-win64-vs18"' configure

# Add vs_ver=18 to gen_msvs_sln.sh: print vs18 line before vs17
perl -i -pe 'if (/^\s+17\) vs_year=2022 ;;$/) { print "\t\t18) vs_year=2026 ;;\n" }' build/make/gen_msvs_sln.sh

# Extend the sln version format assignment to accept vs18 (original: case 1[4-7]))
sed -i 's/1\[4-7\]/1[4-8]/' build/make/gen_msvs_sln.sh

# Extend VS version validation in gen_msvs_vcxproj.sh to accept 18 (original: case 1[4-7]))
sed -i 's/1\[4-7\]/1[4-8]/' build/make/gen_msvs_vcxproj.sh

# Add vs_ver=18 mapping to v145 (insert BEFORE vs17 block)
sed -i '/if \[ "\$vs_ver" = "17" \]; then/i if [ "$vs_ver" = "18" ]; then\n	   tag_content PlatformToolset v145\nfi' build/make/gen_msvs_vcxproj.sh

# Fix AVX512 detection for MSVC: skip GCC-style test when not using GCC
sed -i 's/if disabled gcc; then$/if ! enabled gcc; then/' build/make/configure.sh

./configure --prefix=$FullScriptPath/../local \
--target=$TOOLCHAIN \
--disable-examples \
--disable-unit-tests \
--disable-tools \
--disable-docs \
--enable-static-msvcrt \
--enable-vp8 \
--enable-vp9 \
--enable-webm-io \
--size-limit=4096x4096

make -j$NUMBER_OF_PROCESSORS
make -j$NUMBER_OF_PROCESSORS install
