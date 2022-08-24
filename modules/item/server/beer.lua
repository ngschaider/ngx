local class = M("class");

local Beer = class("Beer", Item);

Beer.static.name = "beer";
Beer.static.label = "Bier";

function Beer:use()
    print("Beer got used!");
    self.destroy();
end

module.Beer = Beer;