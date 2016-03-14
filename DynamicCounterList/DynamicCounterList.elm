module DynamicCounterList where

import Counter
import Html exposing (..)
import Html.Events exposing (onClick)

type alias ID = Int
type alias DynamicCounter = (ID, Counter.Model)
type alias Model = { counters: List DynamicCounter
                   , nextID: ID 
                   }
 
init : List (ID, Counter.Model) -> ID -> Model
init counters id = { counters = counters
                   , nextID = id 
                   }

type Action
  = Add
  | Remove
  | Modify ID Counter.Action

changeCounter : ID -> (DynamicCounter -> DynamicCounter) -> DynamicCounter -> DynamicCounter
changeCounter id change counter =
  let (counterID, _) = counter in
    if id == counterID then
      change counter
    else
      counter

update : Action -> Model -> Model
update action model =
  case action of
    Add -> { counters = (model.nextID, Counter.init 0)::(model.counters)
                  , nextID = model.nextID + 1
                  }
    Remove ->
      case model.counters of
        _::restCounters -> 
          { counters = restCounters
          , nextID = model.nextID - 1
          }
        [] -> model 
    Modify id counterAction ->
      let applyAction action (id, model) =
        (id, Counter.update action model) in
      { model | 
        counters = List.map (changeCounter id (applyAction counterAction)) model.counters }

view : Signal.Address Action -> Model -> Html
view address model =
  let counters = List.map (viewCounter address) model.counters
      remove = button [ onClick address Remove ] [ text "Remove" ]
      insert = button [ onClick address Add ] [ text "Add" ]
  in
      div [] ([remove, insert] ++ counters)

viewCounter : Signal.Address Action -> (ID, Counter.Model) -> Html
viewCounter address (id, model) =
  Counter.view (Signal.forwardTo address (Modify id)) model

