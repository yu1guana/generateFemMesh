(* Generates a mesh which have point markers of all nodes *)
generateFemMesh[region_,
    OptionsPattern[{meshType -> Automatic, bcLength -> Automatic,
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
            "MeshElementStyle" -> Directive[PointSize[0.02]],
            "MeshElementIDStyle" -> Blue]]];

(* Plots a wireframe of a mesh with node and element IDs *)
showMeshWithId[mesh_] :=
    Show[
        mesh["Wireframe"["MeshElementIDStyle" -> Black]],
        mesh["Wireframe"["MeshElement" -> "PointElements",
            "MeshElementIDStyle" -> Blue]]];

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
