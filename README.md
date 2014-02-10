WordSmith
---------
This game is a highly simplified version of a multi-player game, reduced to two
players and further simplified for quick implementation for the HackReactor 48
hour Hackathon. In this two player word game, the aim is to construct a word with
the maximum point value, based on Scrabble letter points.  Each round of the game
consists of each player alternately taking a turn to select a letter. The round
ends when one of the players challenges the other to expose both words, and the
player with the word that has the most points wins.

In the full version, the game is played with many players, taking turns 
sequentially.  And, anagrams are permitted.

Rules of the game:
------------------
1. A player (Player 1) is selected at random
2. Player 1 moves by selecting a letter from A-Z to start the word
3. Player 2 makes his/her move by selecting the next letter
4. Player 1 continues with his/her next move
5. ... Player 2 moves ...
6. This continues until ... (only on his/her turn)
   i. A player issues a "move challenge" to the other player
        If the other player declines the challenge
           a. his/her letter is revoked
           b. the challenger picks the letter
           c. the play continues
        If the other player accepts the challenge,
           a. his letter stays
           b. both players must show their words
           c. player whose word has most point wins the round
  ii. Or, a player issues a "call challenge" to the other player 
    		a. both players must reveal their intended words
    		b. the player wih the word that has most point wins the hand
    		b. if both have the same word, the player who did NOT call wins the hand
7. The next round starts with the winner of the previous round selecting the 	
   first letter.

Additional rules:
-----------------
a. Valid words are selected from an Open Source dictionary provided by 
   Letterpress (https://github.com/atebits/Words)
b. Retraction of a selected letter is never permitted
c. Yes, cheating is easy in this version, but that's pretty lame.
   The anagram version should be more difficult and require someone to at 
   least take the time to write a few lines of code.

Acknowledgments:
----------------
The game server runs on Sinatra (http://www.sinatrarb.com).  The realtime data
access runs on Firebase (https://www.firebase.com).  The client side runs on 
AngularJS framework (http://angularjs.org).  Original Letterpress 
(https://github.com/atebits/Words) dictionary converted from text file to SQLite 
database using a custom NodeJS app.  This was done using the SQLite API from 
(https://github.com/mapbox/node-sqlite3/wiki/API).  Scrabble tile images 
from (http://www.fuzzimo.com), background image from (http://www.subtlepatterns.com).
Knowhow and get it done attitude from HackReactor (http://www.hackreactor.com).

License:
--------
The MIT License
Copyright (c) 2014 Walid Hosseini, http://walidhosseini.com
