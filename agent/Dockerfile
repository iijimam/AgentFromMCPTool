# Agent 用の IRIS
ARG IMAGE=docker.iscinternal.com/docker-intersystems/intersystems/iris-community:2026.3.0AI.136.0
FROM $IMAGE

USER root
WORKDIR /opt/src

RUN mkdir -p /opt/src/data /opt/src/logs \
 && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/src
 
# ビルド中に実行したいスクリプトがあるファイルをコンテナにコピー
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} agent/iris.script .
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} agent/src/ .

# 製品版の場合、ベクトル検索の準備のため、ビルド時にキーコピー必要
#COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} ../iris.key ${ISC_PACKAGE_INSTALLDIR}/mgr/iris.key

USER ${ISC_PACKAGE_MGRUSER}

# IRISを開始し、IRISにログインし、iris.scriptに記載のコマンドを実行しています
RUN iris start IRIS \
    && iris session IRIS < iris.script \
    && iris stop IRIS quietly
