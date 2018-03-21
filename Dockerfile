FROM python:3.6
MAINTAINER wildcloud <wildcloud3@gmail.com>

ENV SCRIPTS_DIR /home/scripts
ENV PKG_DIR /home/pkg
ENV HOME_DIR /home/work
ENV BASE_DIR /home/workspace
ENV LEP_REPO_URL https://github.com/DanBloomberg/leptonica.git
ENV LEP_SRC_DIR ${BASE_DIR}/leptonica
ENV TES_REPO_URL https://github.com/tesseract-ocr/tesseract.git
ENV TES_SRC_DIR ${BASE_DIR}/tesseract
ENV TESSDATA_PREFIX /usr/local/share/tessdata
ENV OPENCV_VERSION="3.4.0"

RUN apt-get update && \
        apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjasper-dev \
        libavformat-dev \
        libpq-dev \
        autoconf \
        autoconf-archive \
        automake \
        checkinstall \
        g++ \
        git \
        libcairo2-dev \
        libicu-dev \
        libpango1.0-dev \
        libpng12-dev \
        libtiff5-dev \
        libtool \
        xzgv \
        zlib1g-dev && \
        pip install numpy pytesseract flask flask-cors && \
        apt-get remove -y python-pip && \
        rm -rf /var/lib/apt/lists/*

WORKDIR /

RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
&& unzip ${OPENCV_VERSION}.zip \
&& mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
&& cd /opencv-${OPENCV_VERSION}/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DENABLE_AVX=ON \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python3.6 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3.6) \
  -DPYTHON_INCLUDE_DIR=$(python3.6 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3.6 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
&& make install \
&& rm /${OPENCV_VERSION}.zip \
&& rm -r /opencv-${OPENCV_VERSION} \
&& mkdir ${SCRIPTS_DIR} \
&& mkdir ${PKG_DIR} \
&& mkdir ${HOME_DIR} \
&& mkdir ${BASE_DIR} \
&& mkdir ${TESSDATA_PREFIX}

# Leptonica
# RUN git ls-remote ${LEP_REPO_URL} HEAD
RUN git clone ${LEP_REPO_URL} ${LEP_SRC_DIR} \
&& cd ${LEP_SRC_DIR} \
&& autoreconf -vi && ./autobuild && ./configure && make && make install \
&& cd ${BASE_DIR} \
&& rm -rf $LEP_SRC_DIR}

# Tesseract
# RUN git ls-remote ${TES_REPO_URL} HEAD
RUN git clone ${TES_REPO_URL} ${TES_SRC_DIR} \
&& cd ${TES_SRC_DIR} \
&& ./autogen.sh && ./configure && LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make && make &&  make install && ldconfig && make training && make training-install \
&& cd ${BASE_DIR} \
&& rm -rf ${TES_SRC_DIR}

#WORKDIR ${LEP_SRC_DIR}
#RUN autoreconf -vi && ./autobuild && ./configure && make && make install

#WORKDIR ${TES_SRC_DIR}
#RUN ./autogen.sh && ./configure && LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make && make &&  make install && ldconfig && make training && make training-install

# osd   Orientation and script detection
RUN wget -O ${TESSDATA_PREFIX}/osd.traineddata https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata \
# equ   Math / equation detection
    && wget -O ${TESSDATA_PREFIX}/equ.traineddata https://github.com/tesseract-ocr/tessdata/raw/3.04.00/equ.traineddata \
# eng English
    && wget -O ${TESSDATA_PREFIX}/eng.traineddata https://github.com/tesseract-ocr/tessdata/raw/4.00/eng.traineddata \
# other languages: https://github.com/tesseract-ocr/tesseract/wiki/Data-Files
    && wget -O ${TESSDATA_PREFIX}/chi_sim.traineddata https://github.com/tesseract-ocr/tessdata/raw/4.00/chi_sim.traineddata
# other languages: https://github.com/tesseract-ocr/tesseract/wiki/Data-Files

ADD ocrWeb.py ${HOME_DIR}/ocrWeb.py

EXPOSE 5000

WORKDIR ${HOME_DIR}
ENTRYPOINT ["python", "ocrWeb.py"]
