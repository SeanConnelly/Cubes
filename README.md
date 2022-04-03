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

### Searching

The Search API is modelled on same simplicity of a search engine such as Google and Bing.

A Search consists of a one or more words where those words must exist in the object.

**Example:-**

Search for all objects with the word Jaberwock

**Request**

http://localhost:52773/cubes/test/object?$query=Jaberwocky

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