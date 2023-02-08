Couple useful commands:

    wsl —shutdown
    wsl --unregister Ubuntu-22.04
    wsl --install Ubuntu-22.04
    notepad "$env:USERPROFILE/.wslconfig"
  
content of `.wslconfig`  
```properties
[wsl2]
memory=32GB
processors=6
```
