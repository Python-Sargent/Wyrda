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
| Expol             | Summon an explosive               |                                       |
| (Empty)           | (does nothing)                    | (also does nothing)                   |

There are no wands for the spell Repetim, as that spell requires a message to relay.
And having a wand to relay a message which you never spoke is useless.

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
Recharge Rate is a number from 0.1 to 1, and it defines the speed at which you recover energy.

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
