# TempoSync

A script for figuring out the best tempo fit for a set of markers in a Reaper project

INSTALLATION:

1- In Reaper, click the "Actions" menu, then "Show action list..."

2- In the Action window click "New Action" then "Load ReaScript". Select the TempoSync.lua file and load it.


USAGE:

1- Enter markers on your project according to the hit points you need in your cue. Make sure your project matches your video framerate.

2- Open the Action window and run the script

3- When prompted, enter your target tempo, desired beats per measure and subdivision. Then click Ok.

4- The script will return a list of results at different tempos along with the amount of exact hits and the total sum of the offset for markers that were not hit.

5- Enter your desired tempo and metric at the 00:00:00:00 timecode.
