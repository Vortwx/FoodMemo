## Reference
1. https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/implementing_modern_collection_views - Implementing Modern Collection Views
(Sorry I can't find the MIT licence for this cuz this is in the Apple Website)

## Introduction
This is an app dedicated for noting down what we want to eat and planning them in advanced so we need not to worry about it.
Using this app, you can add your custom recipe or search in our dedicated recipe library for cooking inspiration. 

After finding all the recipe, it is time to do the planning !
The planning is on a daily basis and we can set various properties we want for the recipe including servings and mealType.
You can also customised your own recipe in the Planning tab with full adding and editing functionality.

Finished adding the plan, you will noticed that the grocery list get updated accordingly. We can view it in a daily or weekly basis for the ease of shopping.

Other than that, if you add the plan for future date, you will see your recipe shown with the reminder under stating when is the time scheduled for the meal. A notification will be triggered 1 hour in advanced for the dedicated eating time to notify user for meal preparation and stuff. Unfortunately, if you set the plan in a past date the notification will not be fired.

Last but not least, you can always check the details by clicking on the plan to see what is the recipe and check out the teaching video in the top right corner.


## Functionality
Looking back to the requirement I set on A1, I have achieved most of what I have written and faced numerous challenges that I didn't think of when working on this application.

Rewinding on the MVP of this application,
it includes
1. Automated Grocery List
2. Planner
3. Customisation of Recipes
4. Preparation Reminder
and they are all implemented

#### This application make use of several technologies including
1. API (Web Services)
2. Core Data
3. Local Notification
4. Deep Linking

#### The features I have left out due to technical difficulties and time constraints are:
1. Note on plan (Realised that this is actually not so useful)
2. Combining grocery list in the same name (Requires ingredient get from API have relatively easy to extract unit, but the unit extracted includes : 1 1/2 tbs, 2 cups, Zest of 1, finely chopped and many others with not unified expression)
3. EventKit that sync the grocery list to reminder (This is actually not involved with Deep Linking technology hence I put the priority of implementing this functionlaity lower)
4. Customisation of Photo and Video URL on custom recipe (This involve technology about imagePicker and AVKit which I have insufficient time to experiment with)
5. Full customisation on everything (
    Still the meal type and meal time are not supporting customisation yet due to excessive time working on other parts of application
)

#### The technical hardship I faced which is not expected when I planned this application
1. Synced status on isCollected button

This should not be the problem if both RecipeLibrary screen & MyRecipeCollections screen are using CoreData as I initially though of. However, the recipe fetched from API should not be using CoreData as this will completely eliminate the reason of using an API.

So to keep track of the isCollected status across these 2 screens, I introduce a manual lookup mechanics which classified recipe collected in My Recipe Collections including API and custom recipe (in coreDataController there is a collectionFetchedResultController for this). Once the recipe is added into collection, Recipe object will check the isChecked status.

Now when I go back to Recipe Library, it will refresh and loop through collections and find any recipe that is extracted from API (There is a uniqueApiId for this, note that this is different to Recipe.id which is for both custom and API recipe). Everytime the Recipe Library Screen refresh it will make sure the collected cell stay collected (check the status programmatically)

2. Deletion Logic on My Recipe Collections

In this application there is no other place dedicated for saving personal recipe. Hence, it is necessary to pay extra attention when dealing with custom recipe deletion. Hence when user wish to uncheck the custom recipe it will have a prompt to double confirm with user about the deletion. Also, when the user tries to delete the recipe that is being used by the plan, the delete action will be denied to ensure the plan doesn't have non existent recipe attached to it.

3. Mechanics for Add/Edit Plan

The logic of add Plan and edit Plan is fused into one function
    There are several scenarios:
    1. Add plan from scratch
    - A new recipe will become visible in My Recipe Collections screen

    2. Add plan from My Recipe Collections (It is designed so that user will not be flooded by same recipe everytime they create a new plan)
    - No new recipe will be added
    - Change made (ingredients) will be sync to the original recipe in My Recipe Collections screen

    3. Edit plan
    - No new recipe will be added
    - Only action happen is update
    - Change made (ingredients) will be sync to the original recipe in My Recipe Collections screen

In this implementation, the behaviour of edit on API recipe will be sync to original recipe is expected as otherwise we will have duplicate API recipe added everytime we add the plan.

4. Excessive Amount of View Controller

A side note, I actually get quite overwhelmed by the view controller I need to add 😵
There are multiple ways to navigate into a screen thus the increment of view controller


5. Local notification management

Surprisingly, implementation of local notification is difficult in this application. As the plan can be deleted, and the recipe inside the plan can be changed, this means that the message inside notification can be outdated. The absence of function to extract notification message adds more challenge on this.

As the message is consists of string only and will not be too large in size (expired notifications will be deleted), I use UserDefault to store the notification message. Everytime a new recipe is added into a plan, a  notification will be scheduled. (The reason notification is not scheduled when a new plan is added is because it might still have no recipe attached to it) When the recipe is detached from the plan, the corresponding notification will be descheduled. As it is coded that all plan change involved detach old recipe and add new recipe into a plan, the scheduling of notification will always work. After the notification is triggered, it will be deleted in UserDefault. To make the change sync across the backend and the Home Page, an User Default Observer is setup in Home Page screen to listen to any User Default change. Note that User Default change is only discoverable if the notifyChange function is invoked.


#### The new functionality added
1. Detail Inspection Screen
2. Deep linking into Youtube for recipe Video


