var cctoken = artifacts.require("./CCToken.sol");
contract('CCToken', function (accounts) {
        it("should have correct init data", function () {
            return cctoken.deployed().then(function (instance) {
                return instance.name
            }).then(function (name) {
                assert.qual(name,"CCtoken");
            });
        });


    }
);