module AsText exposing (moduleToText)

import Dict exposing (..)
import DomainModel exposing (..)
import Set exposing (..)
import String.Interpolate exposing (interpolate)


moduleToText : Module -> String
moduleToText m =
    moduleHeader m
        ++ withClasses m.classes
        ++ withNodes m.nodes
        ++ withLinks m.links


moduleHeader m =
    -- Canonical form.
    String.Interpolate.interpolate
        """{0} is Module {1}{2}.

"""
        [ safely m.id
        , if String.length m.label > 0 then
            """;
    label """ ++ m.label

          else
            """"""
        , case m.sourceFile of
            Just file ->
                """;
    source """ ++ file

            Nothing ->
                """"""
        ]


withClasses : Dict ClassId Class -> String
withClasses classes =
    classes
        |> Dict.values
        |> List.map
            (\class ->
                class.id
                    ++ " is Type"
                    ++ (case class.label of
                            Just label ->
                                """;
    label """
                                    ++ label

                            Nothing ->
                                ""
                       )
                    ++ """."""
            )
        |> String.join """
    
"""


withNodes : Dict NodeId Node -> String
withNodes nodes =
    let
        attribute : String -> Set String -> String
        attribute relation objects =
            "    "
                ++ relation
                ++ " "
                ++ (objects |> Set.toList |> String.join """, 
            """)

        phrases : Node -> String
        phrases node =
            (([ Maybe.map (\class -> " is " ++ class) node.class
              , Maybe.map (\label -> " label " ++ label) node.label
              ]
                |> List.filterMap identity
             )
                ++ (Dict.map attribute node.attributes |> Dict.values)
            )
                |> String.join """;
"""
    in
    (nodes
        |> Dict.values
        |> List.map (\node -> node.id ++ phrases node)
        |> String.join """.
    
"""
    )
        ++ """.
"""


withLinks : Dict LinkId Link -> String
withLinks links =
    let
        attribute : String -> Set String -> String
        attribute relation objects =
            "    "
                ++ relation
                ++ " "
                ++ (objects |> Set.toList |> String.join """, 
            """)

        phrases : Link -> String
        phrases link =
            (([ Just
                    (link.fromNode
                        ++ " -> "
                        ++ link.toNode
                        ++ " : "
                        ++ link.label
                    )
              , Maybe.map (\class -> " is " ++ class) link.class
              ]
                |> List.filterMap identity
             )
                ++ (Dict.map attribute link.attributes |> Dict.values)
            )
                |> String.join """;
"""
    in
    (links
        |> Dict.values
        |> List.map phrases
        |> String.join """.
    
"""
    )
        ++ """.
"""


safely : String -> String
safely using =
    if List.length (String.words using) > 1 then
        "\"" ++ using ++ "\""

    else
        using
