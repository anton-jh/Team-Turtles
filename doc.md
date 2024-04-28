# Team Turtles 2023



## Communication

### Requesting new layer

The request contains the current assignedLayer.
If a restart happens after the request is sent and state saved on server but before turtle gets response:
    Turtle will try again.
    Server can then see that the layer sent by the turtle is not the currently assigned one.
    Server simply repeats the response without assigning yet another new layer.



## Misc

### Filter

`++` = allow all
`--` = deny all
`+t tag` = allow if has tag "tag"
`-t tag` = deny if has tag "tag"
`+n name` = allow if name = "name"
`-n name` = deny if name = "name"

A block that gets denied by an early filter could again be allowed by a later one.
The last filter that apply to the block is the one that counts.

**Example**:
```
--                          Deny all
+t c:ore                    Allow ores
-n minecraft:copper_ore     Deny copper ore
```


## Wishlist

### Handle indestructible blocks

- Bedrock
- End portal frame

If turtle gets blocked by indestructible block, abandon current layer.
If the block is in the corridor, error.


### Handle chests

Empty chest before mining it.



## TODO

