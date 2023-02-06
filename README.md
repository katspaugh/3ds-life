# 3DS hacking

I spent a good portion of the weekend rooting my 2DS, installing a home-brew toolchain on the computer, and writing a game.
Here's a write up of the process.

## Goal
The end goal is to be able to write a home-brew app or a game and run it on the console.

We will be developing on the computer, building and sending the built binaries over Wi-Fi to the console.

## Rooting

There are a lot of methods to root a 3DS, and a lot of mixed information on the Internet, some of which is not relevant anymore due to the latest firmware updates and new hacks that came out.

The current method is called seedminer + boot9strap, and it results in a rooted console that has the same UI as before but a couple of new apps will appear on the Home Screen for things like file management, home-brew app launching, FTP, etc.

Follow this excellent detailed guide step-by-step: [3DS Hacks Guide](https://3ds.hacks.guide/)

<img src="https://user-images.githubusercontent.com/381895/212480538-0b846d07-387e-41fd-8164-85ab1a08089f.jpeg" width="600" />

## Home-brew dev

Once you have a rooted console, we need to set up a dev environment on your computer.

The goto project there is called [devkitpro](http://devkitpro.org).

The easiest way to get it running is to use their [Docker image](https://hub.docker.com/r/devkitpro/devkitarm).

Download the image, run it in Docker, and expose a local folder to it, so that you can edit the code on your PC, but build and send it to the 3DS from the Docker container.

## LovePotion

Now we want to code a game. I’ve chosen Lua to write a game because it’s a simple language and it comes with an excellent framework called Löve.

On the 3DS, there’s a Lua interpreter and a port of Löve, called [LovePotion](https://lovebrew.org).

One part of this framework is [LoveBrew](https://lovebrew.org/#/lovebrew) and this is what we’ll use to build our project.

You need to download the latest LoveBrew binary and put it inside the Docker container. Make it executable via `chmod +x` and place it in `/usr/local/bin` of the Docker container.

It will log any build errors to `/root/.config/lovebrew`.

To create a new project, go to the folder you exposed from your host computer, and run this command:

```bash
lovebrew init
```

This will generate a basic config for your project and put it in a `lovebrew.toml` file.

Next, write some Lua code following the LovePotion/Love2d docs. I’m not going to go into much detail here, but you can see an example in this repo.

Once the code is ready and tested on the computer (using the regular Love2d), build it:

```bash
lovebrew build
```

Next, open your 3DS console, run the Homebrew Launcher, and press `Y`. This will start a server over Wi-Fi and display its IP address so that you can send your build over to the console.

Inside the docker container, run:

```bash
3dslink build/MyProject.3dsx -a 192.168.0.54 -0 sdmc:/3ds/MyProject.3dsx
```

Where `192.168.0.54` is the IP address of the console from the previous step.

## Result
Here's the game I wrote. It's a simple Game of Life that creates cool generative patterns.

<video controls="controls" src="https://user-images.githubusercontent.com/381895/213908522-c846f8d0-b8cd-404a-8323-84ae68f3f249.mov
" width="640" />

## Conclusion

That’s pretty much it. Now you can enjoy hacking on your game or app!
