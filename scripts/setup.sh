SYSROOT=$(realpath $(dirname $_))

echo "setting up sysroot installed at $SYSROOT"

# links below are required by bcc python library which opens those libs with
# dlopen. Not the best solution but a solution
if [[ ! -e $SYSROOT/lib/libbcc.so.0 ]]; then
    ln $SYSROOT/lib/libbcc.so -s $SYSROOT/lib/libbcc.so.0
fi
if [[ ! -e $SYSROOT/lib/libc.so.6 ]]; then
    ln /system/lib64/libc.so -s $SYSROOT/lib/libc.so.6
fi
if [[ ! -e $SYSROOT/lib/librt.so.1 ]]; then
    ln /system/lib64/libc.so -s $SYSROOT/lib/librt.so.1
fi

# attempt to unpack kernel-headers if kernel-headers dir does not exist
if [[ ! -e $SYSROOT/kernel-headers && \
          -e $PACKED_KERNEL_HEADERS_PATH ]]; then
    echo "unpacking kernel headers..."
    ABSOLUTE_PACKED_HERNEL_HEADERS_PATH=$(realpath $PACKED_KERNEL_HEADERS_PATH)
    (cd $SYSROOT && tar xf $ABSOLUTE_PACKED_HERNEL_HEADERS_PATH)
fi

export PATH=$SYSROOT/bin:$PATH
export LD_LIBRARY_PATH=$SYSROOT/lib:$SYSROOT/lib64:$LD_LIBRARY_PATH

# define environment variables bpftrace and bcc need to determine arch and
# kernel source path
export ARCH="arm64"
export BPFTRACE_KERNEL_SOURCE=$SYSROOT/kernel-headers
export BCC_KERNEL_SOURCE=$SYSROOT/kernel-headers
export BCC_SYMFS=/data/local/tmp/symbols

# tell python where to find bcc in case we built the package on ubuntu/debian
export PYTHONPATH=$SYSROOT/lib/python3/dist-packages:$PYTHONPATH

echo "done"
