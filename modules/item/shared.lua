print("loading shared");

ItemConfigs = {
    {
        type = "beer",
        defaultName = "Bier",
        use = function(self)
            self.Destroy();
        end,
    }
}

print("loaded shared");
print(json.encode(ItemConfigs))