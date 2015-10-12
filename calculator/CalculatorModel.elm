module CalculatorModel where

import Char
import Result
import Set
import String

type ButtonType = Regular | Large

buttonSize : ButtonType -> Int
buttonSize size =
  case size of
    Regular -> 60
    Large -> 120

type alias CalculatorState = {
    input : String,
    operator : String,
    number : Float
  }

isOper : String -> Bool
isOper btn = btn `Set.member` (Set.fromList ["+","-","*","/","="])

initialState : CalculatorState
initialState = { number = 0.0, input = "", operator = "" }

step : String -> CalculatorState -> CalculatorState
step btn state =
  if  | btn == "C" -> initialState
      | btn == "CE" -> { state | input <- "0" }
      | state.input == "" && isOper btn -> { state | operator <- btn }
      | isOper btn -> {
            number = calculate state.number state.operator state.input,
            operator = btn,
            input = ""
        }
      | otherwise ->
        { state |
                  input <-
                    if  | (state.input == "" || state.input == "0")
                          && btn == "." -> "0."
                        | state.input == "" || state.input == "0"
                          -> btn
                        | String.length state.input >= 18
                          -> state.input
                        | btn == "."
                            && String.any (\c -> c == '.') state.input
                            -> state.input
                        | otherwise -> state.input ++ btn }

calculate : Float -> String -> String -> Float
calculate number op input =
  let number2 =
        case String.toFloat input of
          Ok n -> n
          Err _ -> 0.0
  in
    if | op == "+" -> number + number2
       | op == "-" -> number - number2
       | op == "*" -> number * number2
       | op == "/" -> number / number2
       | otherwise -> number2

showState : CalculatorState -> String
showState {number, input} =
  if input == "" then toString number else input



