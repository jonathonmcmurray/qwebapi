#!/bin/bash

PKG_NAME="webapi"

QHOME=$PREFIX/q
mkdir -p $QHOME/packages/${PKG_NAME}
cp -r ${SRC_DIR}/webapi/*.q $QHOME/packages/${PKG_NAME}/
