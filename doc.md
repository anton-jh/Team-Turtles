# Team Turtles 2023



## Communication


### Requesting new layer

The request contains the current assignedLayer.
If a restart happens after the request is sent and state saved on server but before turtle gets response:
    Turtle will try again.
    Server can then see that the layer sent by the turtle is not the currently assigned one.
    Server simply repeats the response without assigning yet another new layer.



## Wishlist

### Handle indestructible blocks

- Bedrock
- End portal frame

If turtle gets blocked by indestructible block, abandon current layer.
If the block is in the corridor, error.


### Handle chests

Empty chest before mining it.



## TODO

[ ] Clear previous state when starting new job.
[ ] Recover from turn-desync
[ ] Configurable filter for skipping blocks
