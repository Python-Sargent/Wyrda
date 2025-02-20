![wyrda_screenshot](https://github.com/user-attachments/assets/d4aba802-a3b1-4e73-bb3c-ccf011904938)

# Wyrda
A spellcasting/magic mod for luanti.

## Content

### Spells

Spells can be spoken or inscripted onto wands using Spell Books.

To speak a spell, open chat and say the name of the spell.
Careful what you say during normal conversation though...

To Inscript as Spell you must use an Inscription Table.
Put the Spell Book in the Script Slot, and then put the Wand in the Inscript Slot.

In the result you will get the Wand inscripted with the Spell.

#### Casting by Voice

You can cast any spell by speaking in chat.

* This means that every chat message is filtered looking for the names of spells.
* The first spell said in a message will be the only spell to be cast.
* Spoken spells still take Energy.

#### Wands

There is currently only one type of wand, which is the `wyrda:basic_wand`

#### Secondary Spells

Wands have the ability to cast secondary spells.
These spells are stronger, and usually perform a seperate action, within the same theme.

#### List of Spells (Primary and Secondary)

| Spell             | Primary                           | Secondary                             |
| ----------------- | --------------------------------- | ------------------------------------- |
| Repetim           | Speak without revealing your name | none                                  |
| Risier            | Rise into the air                 | Dash forward                          |
| Fiera             | Set things on fire                | Summon an explosive Fireball          |
| Disperim          | Disperse entities away from you   | Swap positions of entities            |
| Sanium            | Heal your injuries (2HP)          | Summon a ring of Shields to guard you |
| Expol             | Summon an explosive               | Summon a Singularity (see settings)   |
| Flurra            | Throw a freezing snowball         | Summon a field of icicles             |
| Fulst             | Summon a focused lightning bolt   | Summon a ball of lightning            |
| Hazum             |                                   |                                       |
| (Empty)           | (does nothing)                    | (also does nothing)                   |

There are no wands for the spell Repetim, as that spell requires a message to relay.
And having a wand to relay a message which you never spoke is useless.

#### Details

More details on spells

##### Repetim

This spell when said will repeat everything said in that message (without the word 'repetim' that cast the spell)
as a `core.chat_send_to_all()`.

##### Risier

Risier (Primary Spell) adds an upward velocity to your player. This velocity is equal to 15 and is maxed out at 15.
If you have negative velocity (you are falling) the velocity will be subtracted, i.e. -5 + 15 which is 15 - 5.

##### Fiera

This spell's primary function is currently in progress, as it only works in certain situations.
The secondary function spawns an explosive fireball which has a velocity following your look direction.

##### Disperim

The Primary function is to disperse or push entities away from you.
The Secondary ability teleports you with another entitit, swapping positions.

##### Sanium

Primary function is to heal the user 4 health points, or 2 hearts.
The special ability spawns a ring of 6 shields around you, which blocks incoming projectiles and possible direct damage.

##### Expol

The Primary summons an explosive ball which acts as if thrown, when it touches a node it immediately explodes dealing damage and removing terrain.
The Secondary summons a singularity, which is configurable in the settings. The settings allow you to set the maximum size of the singularity
or disable them altogether, when singularities are disabled the secondary function will perform a different explosive action, dealing damage.

##### Flurra

Allows you to throw snowballs that slow players down (Primary Function)
And you can summon a minefield of icicles that inflict damage (1 hp per second) and slow the victim down.

##### Fulst

This spell can summon a focused bolt of lightning where you are looking, which does damage.
And it can also for the secondary ability summon a ball of lightning, which acts as a trap, when an object get's close the ball will strike the object with a bolt of lighting.

##### Hazum

Toxic

### Energy

Energy is equivelent to Mana.
Whenever a magic action is performed (a Spell) energy will be consumed.
There are two variables to energy: Max Energy and Recharge Rate.
Both off which can be viewed and modified with the `/energy` command.

### Energy Command

The Energy Command can be used to modify your Energy Stats.
Max Energy is the Maximum Energy you can recharge before becoming charged.
A full amount is generally considered 20 units. However you can make it 44 units,
if you wish for more energy but still would like it to be symmetrical.
Recharge Rate is a number from 0.1 to 1, and it defines the delay at which you recover energy, a lower number means a faster regeneration of energy.

The `/energy` command has two sections, the subcommand and the parameters.

The Sub Commands are as follows:

`/energy set`

and

`/energy view`

The Energy Set command can modify your energy attributes.

The parameters are as follows:

`/energy set <attribute> <amount>`

where `<attribute>` is either, `energy`, `max_energy`, or `energy_recharge`.
The amount is the value that the attribute will be set to.

The `view` Sub Command will allow you to view your energy stats.
It does not have any parameters and instead returns your energy stats in this format:

`ENERGY / MAX_ENERGY : RECHARGE_RATE`

### Crafting

The Empty Spell Book (`wyrda:empty_spell_book`) is craftable like this:

P = paper, 
B = book, 
S = steel ingot, 
G = gold ingot, 

|  |  |  |
|--|--|--|
|G |S |G |
|P |B |P |
|G |S |G |

---
A wand can be crafted from it's two parts, the Staff and the Gemstone.

S = staff,
G = gemstone

|  |  |  |
|--|--|--|
|  |  |G |
|  |S |  |
|  |  |  |

The Staff can be crafted like this:

G = gold ingot,
S = stick

|  |  |  |
|--|--|--|
|  |G |S |
|G |S |G |
|S |G |  |

The Gemstone can be crafted as follows:

D = diamond,
M = mese crystal

|  |  |  |
|--|--|--|
|M |M |M |
|M |D |M |
|M |M |M |

Spell books cannot be crafted and must be gotten by other means.
I plan to have structures with books in them at some point.


### Settings

Settings in wyrda allow for direct customization of features within the mod.

Black Holes can be disabled or enabled with the `allow_singularities` setting.

You can change settings in-game by using the `/wyrda settings` command.
The settings command operates as follows:

`/wyrda settings <setting> <value>`

For example:

`/wyrda settings allow_singularities true`

Which enables singularities, singularities are off by default due to their overpowered destructive capabilities. You won't miss out if you don't have black holes, this mod is entirely playable without them.

#### List of Settings

Currently the list of settings is as follows:

| Setting Name         | Default | Effect                                | Requires Restart |
|----------------------| ------- | ------------------------------------- | ---------------- |
| allow_singularities  | false   | Whether black holes should be allowed | false            |
| singularity_size     | 50      | Size of black holes if allowed        | false            |
| allow_crafting_wands | true    | Allow wands to be craftable           | true             |
| use_energy           | true    | Use the energy system                 | true             |
| allow_cbv            | true    | Allow spells to be Cast By Voice      | false            |

Settings can be changed in the menu by going to Settings > Mods > Wyrda.
If it is easier, you can run the `/wyrda settings` command, but some settings require a restart.

### Nodes

With the release of Feb 20th's version, there are now a suite of nodes to choose from.
These nodes are for Structures. The structures are the perfect way to get spell books in survival.

The nodes fall under the group name of Ghenstone, a new highly durable stone.

The list of nodes are as follows:

* Ghenstone
* Shattered Ghenstone
* Molding Ghenstone
* Overgrown Ghenstone
* Clean Ghenstone
* Smoothed Ghenstone
* Carved Ghenstone
* Tiled Ghenstone
* Darkened Ghenstone
* Ghenstone Bricks
* Clean Ghenstone Bricks
* Mold
* Overgrowth

And the stairs and slabs variants of these nodes:

* Ghenstone
* Shattered Ghenstone
* Molding Ghenstone
* Overgrown Ghenstone
* Clean Ghenstone
* Smoothed Ghenstone
* Carved Ghenstone
* Tiled Ghenstone
* Darkened Ghenstone
* Ghenstone Bricks
* Clean Ghenstone Bricks

---

With these new nodes is a new node called an Emblem.
There is one Emblem for each spell.

When you walk onto this node it will cast the spell.
For example, the Risier Emblem will luanch you upwards, or slow your fall,
just like the wand, or casting by voice.

Emblems are useful if you want a player to be able to access an area even if they don't have the wand and cannot say spells.