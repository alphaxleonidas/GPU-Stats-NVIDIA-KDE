# GPU-Stats-NVIDIA-KDE
GPU temp and Power applet for KDE plasma 6


# Instructions

```
cd ~

git clone https://github.com/alphaxleonidas/GPU-Stats-NVIDIA-KDE.git

cp -r GPU-Temp-NVIDIA-KDE/* ~/.local/share/plasma/plasmoids/

```

Now log out and relogin.

Add the applet from KDE Task Bar.

For testing, use: 

```
kquitapp6 plasmashell
  rm -rv ~/.cache/plasma*
  plasmashell &
```
This will delete cache and restart the session in the same shell. 
