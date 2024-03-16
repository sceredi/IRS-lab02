# IRS Second Activity
## Objective
Move the robot towards a light source as fast as possible avoiding obstacles

## Solution implemented
### Task definition
The basic idea of the solution is to decide what is the most important task for the robot at a given time (every tick).
This has been implemented using a function named `define_task()`, this function decides what task is the most
important for the robot in a imperative way. The priority was if the robot is close to the light then the task is `light_found`,
otherwise if the robot is close to an obstacle the task is `collision_avoidance`, if the robot wasn't detecting the light source
then the task would be `random_walk` and if none of those were true, then the task was `move` (towards the light source).

### Use of tasks
Implementing this idea of tasks was beneficial as it allowed for a less cluttered logic implementation. This made it possible
to easily color the leds of the robot based on the task currently being done, thus allowing for easy visual debugging.
The tasks job were the following:
- `light_found`: When the robot was close to the light it would simply stop moving and turn on all the leds to the yellow color.
- `collision_avoidance`: When doing the collision avoidance task the robot leds would turn red and the robot would spin on itself
and face a direction without objects it could collide with.
- `random_walk`: When doing the random walk task the leds would turn green and the robot would randomly walk around the arena.
- `move`: When doing the move task the robot would turn towards the brightest light source, when facing it in front it would go as
as fast as possible in its direction.

## Problem faced
### Solved
### Partially solved
### Unsolved

