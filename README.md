# IRS Second Activity
## Objective
Move the robot towards a light source as fast as possible avoiding obstacles
### Addidional constraints
It is imperative that the robot does not collide with any obstacles (walls, blocks, other robots, ...).

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
The first problem encountered was being able to traverse obstacles angles while the light source was behind them. In this case the robot
was switching modes one tick after the other and remaining in position as the collision avoidance task was making it avoid the obstacle,
and immediately after the move task was making it go back towards the obsacle. This problem was solved by adding some randomicity in the robot
move task, basically making it select randomly in a given range the speed of both wheels instead of using hardcoded values, while keeping
the collision avoidance movements "deterministic" as the only randomness they would have is based on sensors and actuators noise.

### Unsolved
The biggest problem faced and still unsolved is one in which in the arena a situation like the following presents itself:
- There is a structure similar to a funnel in which:
    - 2 walls are in the shape of an "L" with a bit of space in the middle
    - Behind this middle bit the light source is present

In this case the problem that arises is that the robot will get inside the funnel and wont be able to exit it. The reason for this
behaviour is that it's easy for the robot to avoid obstacles and follow the light source, so it will naturally get to the "bottom"
of the funnel, once inside it is impossible for the robot to exit because as soon as it is not anymore in the obstacle avoidance task
it will start going towards the light making it get stuck in the bottom of the funnel.

