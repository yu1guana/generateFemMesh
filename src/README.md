# ディレクトリ 構成

このディレクトリ の構成は以下のようになっている。

| ファイル名                     | 内容                                                         |
| :----------------------------- | ------------------------------------------------------------ |
| README.md                      | このファイル。                                               |
| generateFemMesh.wl             | 自作関数が定義されているWolfram scriptファイル。             |
| meshExample.ipynb              | 自作関数を使用してメッシュを生成した例を記載したJupyter notebook。 |
| howToMakeGenerateFemMesh.ipynb | 自作関数をどのようにして作成したかがわかるJupyter notebook。 |
| checkScript.ipynb              | 自作関数が正しく動いていることの確認するためのJupyter notebook。 |

# 自作関数の説明

## generateFemMesh

### 戻り値

`ElementMesh`

### 引数

| 変数名                            | 説明                                                         |
| --------------------------------- | ------------------------------------------------------------ |
| region                            | 必須。領域データ。                                           |
| meshType                          | オプショナル（デフォルトは`Automatic`）。メッシュの種類を選ぶ。1次元領域に対しては`LineElement`、2次元領域に対しては`TriangleElement`か`QuadElement`、3次元領域に対しては`TetrahedronElement`か`HexahedronElement`が指定できる。 |
| continuationBoundaryMeshGenerator | オプショナル（デフォルトは`False`）。`BoundaryMeshGenerator`に`Continuation`を指定するかどうかを決める。詳細は[公式ドキュメント](https://reference.wolfram.com/language/FEMDocumentation/ref/ToElementMesh.html.ja?source=footer)を参照。 |
| bcLength                          | オプショナル（デフォルトは`Automatic`）。領域境界要素内にある線要素の最大長を指定する。 |
| length                            | オプショナル（デフォルトは`Automatic`）。要素内にある線要素の最大長を指定する。 |
| area                              | オプショナル（デフォルトは`Automatic`）。要素内にある2次元要素の最大面積を指定する。 |
| volume                            | オプショナル（デフォルトは`Automatic`）。要素内にある3次元要素の最大体積を指定する。 |
| pointMarkerFunction               | オプショナル（デフォルトは`0&`）。節点マーカーの付け方を決める関数を指定する。この関数の引数は座標を表すリストである。すなわち`{x}`、`{x, y}`、`{x, y, z}`のいずれかである。デフォルトでは全ての節点マーカーはゼロとなる。 |

### 説明

元々のメッシュ生成関数`ToElementMesh`を利用すると節点マーカーが領域境界にしか付与されないが、この関数を使うと全ての節点に対してマーカーが付与される。必須引数の`region`は`Rectangle`や`ImplicitRegion`などを利用して作成する。

## showPointMarkers

### 引数

| 変数名 | 説明                      |
| ------ | ------------------------- |
| mesh   | 必須。`ElementMesh`データ |

### 説明

`ElementMesh`データを受け取り、節点番号と節点マーカーとともにメッシュのワイヤーフレームを表示する。

## showMeshWithId

### 引数

| 変数名 | 説明                      |
| ------ | ------------------------- |
| mesh   | 必須。`ElementMesh`データ |

### 説明

`ElementMesh`データを受け取り、節点番号と要素番号とともにメッシュのワイヤーフレームを表示する。

## getDimension

### 戻り値

メッシュの次元。

### 引数

| 変数名 | 説明                      |
| ------ | ------------------------- |
| mesh   | 必須。`ElementMesh`データ |

## getNumNodes

### 戻り値

メッシュが持つ節点の数

### 引数

| 変数名 | 説明                      |
| ------ | ------------------------- |
| mesh   | 必須。`ElementMesh`データ |

## getNumElements

### 戻り値

メッシュが持つ要素の数

### 引数

| 変数名 | 説明                      |
| ------ | ------------------------- |
| mesh   | 必須。`ElementMesh`データ |

## getNumNodesInEachElement

### 戻り値

メッシュ内の各要素が持つ節点の数

### 引数

| 変数名 | 説明                      |
| ------ | ------------------------- |
| mesh   | 必須。`ElementMesh`データ |

## getNumNeighborElementsInEachElement

### 戻り値

メッシュ内の各要素が持つ隣接要素の数

### 引数

| 変数名 | 説明                      |
| ------ | ------------------------- |
| mesh   | 必須。`ElementMesh`データ |

## getCoordinate

### 戻り値

節点の座標値

### 引数

| 変数名 | 説明                                                         |
| ------ | ------------------------------------------------------------ |
| mesh   | 必須。`ElementMesh`データ                                    |
| iNode  | 必須。節点番号。                                             |
| iAxis  | 必須。_x_、_y_、_z_座標を指定する整数（1、2、3のいずれか）。 |

## getPointMarker

### 戻り値

節点マーカー

### 引数

| 変数名 | 説明                      |
| ------ | ------------------------- |
| mesh   | 必須。`ElementMesh`データ |
| iNode  | 必須。節点番号。          |

## getNodeInEachElement

### 戻り値

要素内節点の節点番号

### 引数

| 変数名   | 説明                                         |
| -------- | -------------------------------------------- |
| mesh     | 必須。`ElementMesh`データ                    |
| iElement | 必須。要素番号。                             |
| iOrder   | 必須。要素内の何番目の節点かを指定する整数。 |

## getNeighborElement

### 戻り値

隣接する要素の要素番号

### 引数

| 変数名   | 説明                                           |
| -------- | ---------------------------------------------- |
| mesh     | 必須。`ElementMesh`データ                      |
| iElement | 必須。要素番号。                               |
| iOrder   | 必須。要素の何番目の隣接要素かを指定する整数。 |

## outputNodeDatas

### 引数

| 変数名     | 説明                       |
| ---------- | -------------------------- |
| mesh       | 必須。ElementMeshデータ。  |
| regionName | 必須。領域名を表す文字列。 |

### 説明

節点座標に関する情報をファイルregionName.nodeに出力する。
ファイルフォーマットはメッシュ生成ソフト[Triangle](https://www.cs.cmu.edu/~quake/triangle.html)のnodeファイルに従う。

## outputElementDatas

### 引数

| 変数名     | 説明                       |
| ---------- | -------------------------- |
| mesh       | 必須。ElementMeshデータ。  |
| regionName | 必須。領域名を表す文字列。 |

### 説明

どの要素にどの節点が含まれているかに関する情報をファイルregionName.eleに出力する。
ファイルフォーマットはメッシュ生成ソフト[Triangle](https://www.cs.cmu.edu/~quake/triangle.html)のeleファイルに従う。

## outputNeighborDatas

### 引数

| 変数名     | 説明                       |
| ---------- | -------------------------- |
| mesh       | 必須。ElementMeshデータ。  |
| regionName | 必須。領域名を表す文字列。 |

### 説明

隣接要素に関する情報をファイルregionName.neighに出力する。
ファイルフォーマットはメッシュ生成ソフト[Triangle](https://www.cs.cmu.edu/~quake/triangle.html)のneighファイルに従う。

## outputMeshDatas

### 引数

| 変数名     | 説明                       |
| ---------- | -------------------------- |
| mesh       | 必須。ElementMeshデータ。  |
| regionName | 必須。領域名を表す文字列。 |

### 説明

`outputNodeDatas`と`outputElementDatas`、`outputNeighborDatas`を順番に実行する。