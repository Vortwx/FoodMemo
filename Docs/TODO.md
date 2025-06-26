1. groceries need to do with reorderable list

Listen to add ingredients
- RecipeLibrary (recipe tab)
- PlannerConfiguration (edit tab)
- groceries

Listen to add ingredints into recipe
- the same two above

Listen to add recipes
- same two above 

Listen to add recipes into plan
- adjustablePlanner in edit

Listen to add plan 
- edit tab 


Planner button can go to see the plan itself (should have an additional screen for this)

- Menu Action for Add / Edit
How to implement edit?


All recipe input measureName only



Check if the recipe deleted is involved in any plans
If there is, restrict the deletion 
(1. either change plan's recipeMember or delete the plan)


Day collection on top of Plan
Grocery List grouping
Schedule Local Notification from Other VC (just call appDelegate.scheduleLocalNotif)


meaning of deep linking ?

TO-DO:
1. let nonadjustable click can link to detail inspection screen too (can't link into tab view controller) (v)

2. finish detail inspection screen (v)

3. complete edit plan (v)
(Fixed by setting up in controller viewDidLoad, if they got value then they will set it if not they pass )

4. test nextPlan functionality after edit recipe in plan (v)

5. pass the ingredient into ingredient table for showing & editing purpose (v)
(call a function to internally update ingredient table whenever viewDidlLoad is called)

6. fix the constraint
7. start to beautify and debug
8. write comment and end 

9. delete due reminder (v)
(Fixed by delete the message immediately after notification triggered)

10. recipe library seems broken (it didn't properly adding but repeating after 25)
(The problem lies in that API doesn't support pagination beyond 25 searched results)

11. set breakfast as default meal type even don't touch it (v)
(Achieved by setting menu)


How to separate previously available ingredients and newly added ingredient


No edit photo and URL functionality for now
(all existing photo & URL will preserved, all non-exisiting photo & URL will return nothing)
Photo should have a default

//-------------------------------
- Request Images
- Don't add reminder if the time is less than current time
- When edit we can change to other recipe or do minor changes {
    recipe = existingRecipe doesnt always work
}
(What I want to achieve: Edit will not add new recipe)

// DO I need to manually add a de facto pagination ?

// custom recipe problem

// bug exist in same recipe being added 
