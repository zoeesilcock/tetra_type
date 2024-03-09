# Tetra Type

A prototype of an on-screen keyboard where any letter is within four steps of the initial position. The aim is to create an effective way of entering text with a game controller or TV remote, without taking up too much screen space. 

Currently it has directonal input as well as a select input which is suitable for TV remotes. Game controllers could add more inputs for more efficient input, like: return to center, space, backspace and move cursor left/right.

## Options

* **Wrap around**: This wraps the cursor around to the other side of when going past the edges.
* **Auto reset**: This resets the cursor position to the center after a certain amount of time since last input.

## Layout

The first layout that has been implemented is based on an alphabetical order where the first letters of the alphabet are closest to the center and spiral outwards, ending with some punctuation on the outer edge.

A better way to organize the letters is likely to do some statistical analysis of a language and place the most used letters closest to the center. An additional step would be to take the most common letter to follow each letter into account. I plan to investigate these ideas in a separate project and use the findings to implement a better layout here.
