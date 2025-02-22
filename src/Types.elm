module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (..)
import DomainModel exposing (..)
import LexerTypes exposing (..)
import Parser exposing (..)
import Set exposing (..)
import Time exposing (Posix)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , message : String
    , diagramList : List DiagramId -- full list of what is in the backend
    , moduleList : List ModuleId -- ditto
    , modules : Dict ModuleId Module -- loaded and active.
    , aModule : Maybe Module -- being edited.
    , diagrams : Dict DiagramId Diagram
    , contentEditArea : String -- place to enter and edit modules and diagrams
    , tokenizedInput : List Token -- live parsing and errors.
    , visual : Maybe String -- will become a 3d visualisation.
    , parseStatus : Result String (Set Triple)
    }


type alias BackendModel =
    { message : String
    , modules : Dict ModuleId Module
    , diagrams : Dict DiagramId Diagram
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | UserSelectedDiagram DiagramId
    | UserUpdatedContent String
    | NoOpFrontendMsg
    | UserClickedSave


type ToBackend
    = NoOpToBackend
    | DiagramChangedAtFront Diagram -- leaves some room for optimisation!
    | AskForDiagramList
    | AskForDiagram DiagramId
    | SaveModule Module


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected


type ToFrontend
    = NoOpToFrontend
    | DiagramList (List DiagramId)
    | DiagramContent Diagram -- sub-optimal, may want to know clientId to avoid feedback loop.
    | ModuleList (List ModuleId)
