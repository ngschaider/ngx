local Beer = OOP.ExtendClass("Beer", function(self, ...)
    self.super(...);

    self.use = function()
        print("Beer got used!");
        self.destroy();
    end;
end);

Beer.name = "beer";
Beer.label = "Bier";

Beer.Create = function()
    Item.Create(Beer);
end;

module.Beer = Beer;