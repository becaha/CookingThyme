Cooking Thyme

Requirements (with a yes or no signifying completion and an explainination if no):
    
    Recipe View
        No - Having to scroll up and back from ingredients to directions to see amounts- have a sidebar with ingredients that splits screen or a popover (I didn't end up doing this because I felt that the sidebar made the recipe feel too cluttered.)
        Yes - Editable
        No - Commentable (Seemed like a less important feature)
        Yes - Public or private
        Yes - Pictures
        Yes - Can save recipe to a category
        Yes - Add ingredients to shopping list
    Recipe Book View
        Yes - Recipes organized by categories
        Yes - Can move recipes around
    Public Recipes
        Yes - Can search the database for recipes
        Yes - can add recipes to own recipe book
    *** Stretch Goals ***
    No - Calendar View
        No - Can play meals on days
        No - Reminders about meals, how long it takes to make? When you need to start cooking?
    Timer
        Yes - timer for cooking
    Yes - Shopping List
        No - Memory of recent items on list
        Yes - Checkable
        
Database:

    The Database used consists of RecipeCollection, RecipeCategory, Recipe, Ingredient, Direction, RecipeImage, and ShoppingItem tables.
    
Recipe Collection:

    A user has a collection of his/her own recipes which he/she can edit by editing, adding, and deleting ingredients, directions, and images. The user can move around the recipes in categories to organize them.
    
Ingredients/Servings:

    I did some extra calculations to be able to change the ingredient amount when the serving size was changed. Something I want to do next is increase this accuracy by adding for example 1 tbsp and 1/2 tsp to get the amount exactly right.

Images:
    
    Images for the recipes could be imported through the camera roll or by pasting a URL.
    
Recipe Search:

    For getting public recipes, I used the Tasty API to be able to search with a query for a set of recipes. I lazy loaded the recipes so when a user clicks on a recipe name, the recipe will be retrieved from the API. My favorite part of the app is that you can take a public recipe and copy it into your recipe collection. Once copied, you can edit it just like any other of your recipes.
    
Timer:

    The Timer took a lot of work on the animation side to get the circle around the time to countdown with the time left. I needed the time to be accurate (publishing every 1/50 of a second) in order to make pausing and resuming look smooth. This many publishes, however, bogged down the app, so I had to do some extra counting and calculations in order to keep it smooth and working. I also made it global so the alert will go off even if you have left the timer screen.

Shopping Items:
    
    The shopping items are simple - a checklist of things to buy. The cool feature is that in a recipe view, you can add its ingredients straight to the shopping list.

Comments:

    I want to keep working on the project, so I left some code commented out but not deleted so I could go back and work on it.

Effort:

    I love this project. I am really proud of what it is now, and I'm excited to keep working on it. I've worked on it for an average of 5-8 each week day. I definitely was working hard to get as much content in the app, so the focus was more on content over look. Even so, I feel like I put in good effort to make the animations and layouts look clean and nice.
