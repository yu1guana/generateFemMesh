(* Generates a mesh which have point markers of all nodes *)
generateFemMesh[region_,
    OptionsPattern[{meshType -> Automatic, continuationBoundaryMeshGenerator -> False, bcLength -> Automatic,
        length -> Automatic, area -> Automatic, volume -> Automatic, pointMarkerFunction -> (0&)}]] :=
            Function[mesh, ToElementMesh[
                "Coordinates" -> mesh["Coordinates"],
                "MeshElements" -> mesh["MeshElements"],
                "BoundaryElements" -> {Head[#][#[[1]]]}&[mesh["BoundaryElements"][[1]]],
                "PointElements" -> {PointElement[Partition[Range[Length[#]],1],
                    OptionValue[pointMarkerFunction]/@#]}&[mesh["Coordinates"]]
            ]][ToElementMesh[region,
                "MeshOrder" -> 1,
                "MeshElementType" -> OptionValue[meshType],
                "BoundaryMeshGenerator" -> If[OptionValue[continuationBoundaryMeshGenerator], "Continuation", Automatic],
                "NodeReordering" -> True,
                "MeshQualityGoal" -> "Maximal",
                "MaxBoundaryCellMeasure" -> OptionValue[bcLength],
                "MaxCellMeasure" -> {"Length" -> OptionValue[length],
                    "Area" -> OptionValue[area], "Volume" -> OptionValue[volume]}]
            ];

(* Plots a wireframe of a mesh with node IDs and point markers *)
showPointMarkers[mesh_] :=
    Show[
        mesh["Wireframe"],
        mesh["Wireframe"["MeshElement" -> "PointElements",
            "MeshElementMarkerStyle" -> Red]],
        mesh["Wireframe"["MeshElement" -> "PointElements",
            "MeshElementIDStyle" -> Blue]]];

(* Plots a wireframe of a mesh with node and element IDs *)
showMeshWithId[mesh_] :=
    Show[
        mesh["Wireframe"["MeshElementIDStyle" -> Black]],
        mesh["Wireframe"["MeshElement" -> "PointElements",
            "MeshElementIDStyle" -> Blue]]];

(* Gets informatino which is necessary to use output function *)
getDimension[mesh_] := mesh["EmbeddingDimension"];
getNumNodes[mesh_] := Length[mesh["Coordinates"]];
getNumElements[mesh_] := Length[mesh["MeshElements"][[1,1]]];
getNumNodesInEachElement[mesh_] := Length[mesh["MeshElements"][[1,1,1]]];
getNumNeighborElementsInEachElement[mesh_] := Length[mesh["ElementConnectivity"][[1,1]]];
getCoordinate[mesh_, iNode_, iAxis_] := mesh["Coordinates"][[iNode, iAxis]];
getPointMarker[mesh_, iNode_] := mesh["PointElements"][[1, 2, iNode]];
getNodeInEachElement[mesh_, iElement_, iOrder_] :=
    mesh["MeshElements"][[1, 1, iElement, iOrder]];
getNeighborElement[mesh_, iElement_, iOrder_] :=
    If[mesh["ElementConnectivity"][[1, iElement, iOrder]] == 0, -1,
        mesh["ElementConnectivity"][[1, iElement, iOrder]]];

(* Outputs a node file *)
outputNodeDatas[mesh_, regionName_] :=
    (
        outStream = OpenWrite[regionName <> ".node"];
        WriteLine[outStream,
            StringRiffle[ToString/@{getNumNodes[#], getDimension[#], 0, 1}&[mesh]]]
        Do[(
            WriteLine[outStream,
                StringRiffle[ToString/@
                    Join[{#2},
                        Table[FortranForm[getCoordinate[#1, #2, iAxis]],
                            {iAxis, 1, getDimension[#1]}],
                        {getPointMarker[#1, #2]}
                    ]&[mesh, iNode]]]
        ), {iNode, 1, getNumNodes[mesh]}];
        Close[outStream];
    );

(* Outputs an element file *)
outputElementDatas[mesh_, regionName_] :=
    (
        outStream = OpenWrite[regionName <> ".ele"];
        WriteLine[outStream,
            StringRiffle[ToString/@{getNumElements[#], getNumNodesInEachElement[#], 0}&[mesh]]];
        Do[(
            WriteLine[outStream, StringRiffle[ToString/@
                Join[{#2},
                    Table[getNodeInEachElement[#1, #2, iOrder],
                        {iOrder, 1, getNumNodesInEachElement[mesh]}]
                ]&[mesh, iElement]]]
        ), {iElement, 1, getNumElements[mesh]}];
        Close[outStream];
    );

(* Outputs a neigbor files *)
outputNeighborDatas[mesh_, regionName_] :=
    (
        outStream = OpenWrite[regionName <> ".neigh"];
        WriteLine[outStream,
            StringRiffle[
                ToString/@{getNumElements[#], getNumNeighborElementsInEachElement[#]}&[mesh]]];
        Do[(
            WriteLine[outStream,
                StringRiffle[ToString/@
                    Join[{#2},
                        Table[getNeighborElement[#1, #2, iOrder],
                            {iOrder, 1, getNumNeighborElementsInEachElement[#1]}]
                    ]&[mesh, iElement]]]
        ), {iElement, 1, getNumElements[mesh]}];
        Close[outStream];
    );

(* Outputs node, element, neigbor files *)
outputMeshDatas[mesh_, regionName_] :=
    (
        outputNodeDatas[#1, #2];
        outputElementDatas[#1, #2];
        outputNeighborDatas[#1, #2];
    )&[mesh, regionName];
