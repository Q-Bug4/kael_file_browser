# kael_file_browser
A simple Flutter project to play and sort(move) your photos and videos.

For now, just tested this app on Linux and Windows 10.

## Usage
1. Click the `Open folder` button to select folder and play media. 
2. Click the `Move conf` button to edit movement. Given example below:

```json
{
  "path":  "/home/qbug/Media",
  "activate":  "default",
  "cases":  {
    "default":  {
      "Cats": "/home/qbug/photo/cats",
      "Sport": "/home/qbug/video/sport"
    }
  }
}
```
**Description**:

  - `path`: The directory you opened last time.
  - `activate`: Select one of the `cases` you set. 
  - `cases`: Define which buttons you need and where the file will be moved to when a button is clicked. The key is button name when the value is the directory that opening file will be moved to.

3. Complete the json config and click `OK`. 
4. Now check the bottom bar, there are some new movement buttons. When you click them, the opened file will be move into 

## TODO
- [x] View photo
- [x] View video
- [x] Open folder
- [x] Run shell/script
- [x] Dialog with shell error msg
- [x] Undo movement
- [x] Custom file movement
- [x] Input validation
- [x] Beautify movement input dialog
- [x] Video position controll bar
- [x] Remember last open folder
- [x] Only show control bar when playing videos or gifs
- [x] File sorting
- [x] Multi lines for custom buttons
- [x] Move control button into sidebar
- [x] Click media player to play/pause instead of clicking button
- [x] Cur time at left; end time at right
- [x] Default move dst
- [x] Use `setState` correctly
- [ ] Refactor code - continuous
  - [ ] Use interface
  - [ ] Add unit test
- [ ] Gif control 
- [ ] Move config quick save
- [ ] Recursive list files
- [ ] Random open file
- [ ] Shortcut
- [ ] Custom Shortcut
- [ ] ~~Custom bottom button and shell/script~~

## Bugs
- [x] Controll bar position overflow
- [x] Set play blank after move the lastest file
- [x] init local movement
- [x] Can not open files whose filename contains `#`
- [ ] (In process) Broken file cause crash
- [ ] Remove file and quickly click player cause crash