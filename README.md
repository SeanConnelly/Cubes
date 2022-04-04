```
░█████╗░██╗░░░██╗██████╗░███████╗░██████╗
██╔══██╗██║░░░██║██╔══██╗██╔════╝██╔════╝
██║░░╚═╝██║░░░██║██████╦╝█████╗░░╚█████╗░
██║░░██╗██║░░░██║██╔══██╗██╔══╝░░░╚═══██╗
╚█████╔╝╚██████╔╝██████╦╝███████╗██████╔╝
░╚════╝░░╚═════╝░╚═════╝░╚══════╝╚═════╝░
```    
### A Search Engine Database

### Introduction

Cubes are data silos for storing buckets of text based objects, such as:-

* HTML
* JSON
* Source Code
* XML
* FHIR
* CDA
* HL7v2

Cubes provides a RESTful API for creating, fetching, updating and deleting objects in a Cube.

Objects are automatically indexed using a matrix of word indexes.

*This project is a proof of concept for using globals as a fast index for searching any type of text. The solution is currently unrefined and inperfect on the edges, but it does demonstrate the power and speed of globals for custom requirements*

### Searching

The Search API is modelled on the same simplicity of a search engine such as Google and Bing.

A Search consists of one or more words where those words must exist in the object.

**Example:-**

Search for all objects with the word Jaberwock

**Request**

http://localhost:52773/cubes/test/object?$query=Jaberwock

**Response**

The response returns an array of matches that contain the Cube ID, the Object ID, the line number and line that the word was found.

```
[
    [
        1,
        "Jabberwock",
        1,
        "6",
        "Beware the Jabberwock, my son"
    ],
    [
        1,
        "Jabberwock",
        1,
        "17",
        "The Jabberwock, with eyes of flame,"
    ],
    [
        1,
        "Jabberwock",
        1,
        "26",
        "And hast thou slain the Jabberwock?"
    ]
]
```

### Example

Cubes can be used to store, index and search any type of text.

As an example the project now includes a "Cubes.Tools" class that loads all the source code from the %SYS namespace into a Cube.

Here we can see a screen shot of a simple web search page that uses the Cubes API to fetch search results for all occurences of "classmethod" in the %SYS source code Cube.

![Web Search Screenshot](/screen-shot.png)
