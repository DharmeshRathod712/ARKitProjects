## ARKEA

This is an attempt to create an AR app with the similar functionality as that of IKEA Store App which allows you to place digital 3D object(like Chairs, Tables, Vase, etc..) at specified target on horizontal surface in real world using your iPhone camera.

# Usage:
- First try to detect the horizontal surface by moving your devicce hroziontally 
- Once the surfacce is detected you will see target pointer on the surface.
- Move the target on horizontal surface by moving your device to place the object
- Tap on the target and object will be placed
- You can move the object horizontally/vertically by left Joystick button which is placed at the bottom left part of the screen
- You can rotate the object 360 degrees by right Joystick button which is placed at the bottom right part of the screen
- You can scale/resize the object by pinch gesture on the object

I have integrated Joystick 🕹 functionality to move and rotate the 3D object. Joystick buttons are not always visible or enabled but once you place the object on the horizontal surface in real world and when you tap/move your finger at bottom left or bottom right corner of the screen buttons will show up. Left button (larger one) allows you to move the 3D object Vertically or Horizontally and Right button (smaller one) allows you to rotate the 3D object 360 degrees. You can also resize(scale) the 3D object with pinch gesture on that object.

Some of the concepts of ARKit and SceneKit used in this project are 
* ```ARWorldTrackingConfiguration```
* ```SCNNode```
* ```SCNPlane``` 
* ```SCNMaterial```
* ```SCNVector3```
* ```SCNAction```
* ```SCNScene```
* ```SKView```


# CREDITS:

Thanks to @MitrofD and his awesome TLAnalogJoystick library, implementing Joystick 🕹 functionality in this project was possible. Below is the link of the library 🤩.

![ARKit/SceneKit JoyStick](https://github.com/MitrofD/TLAnalogJoystick)


# Final Output looks something like below .gif

![AR Resume Output](https://github.com/DharmeshRathod712/ARKitProjects/blob/master/ARResume/Output/Output.gif)
