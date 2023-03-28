# 3DS hacking

I spent a good portion of the weekend rooting my 2DS, installing a home-brew toolchain on the computer, and writing a game.
Here's a write up of the process.

## Goal
The end goal is to be able to write a home-brew app or a game and run it on the console.

We will be developing on the computer, building and sending the built binaries over wi-fi to the console.

## Rooting

There are a lot of methods to root a 3DS, and a lot of mixed information on the Internet, some of which is not relevant anymore due to the latest firmware updates and new hacks that came out.

The current method is called seedminer + boot9strap, and it results in a rooted console that has the same UI as before but a couple of new apps will appear on the Home Screen for things like file management, home-brew app launching, FTP, etc.

Follow this excellent detailed guide step-by-step: [3DS Hacks Guide](https://3ds.hacks.guide/)

<img src="https://user-images.githubusercontent.com/381895/212480538-0b846d07-387e-41fd-8164-85ab1a08089f.jpeg" width="600" />

## Home-brew toolkit

Once you have a rooted console, we need to set up a dev environment on your computer.

The goto project there is called [devkitpro](http://devkitpro.org).

The easiest way to get it running is to use their [Docker image](https://hub.docker.com/r/devkitpro/devkitarm).

Download the image, run it in Docker, and expose a local folder to it, so that you can edit the code on your PC, but build and send it to the 3DS from the Docker container.

## Coding

Now we want to code a game. The easiest is to use C. DevkitPro comes with [a bunch of examples](https://github.com/devkitPro/3ds-examples) to get you started.

After writing the code, build the game:

```
make clean && make
```

This will create a .3dsx file.

Now we want to send it to the console over wi-fi. Launch the Homebrew Launcher on the 3DS and press Y. It will show you the IP address of the console in the local network.

From the docker container, send the file like so:

```bash
3dslink build/MyProject.3dsx -a 192.168.0.54 -0 sdmc:/3ds/MyProject.3dsx
```

Where `192.168.0.54` is the IP address of the console from the previous step.

## Result
Here's the game I wrote. It's a simple Game of Life that creates cool generative patterns.

<video controls="controls" src="https://user-images.githubusercontent.com/381895/228176276-173d1b1e-06df-4691-8f5e-ef9b9e40aa7c.mov" />

## Conclusion

That’s pretty much it. Now you can enjoy hacking on your game or app!
