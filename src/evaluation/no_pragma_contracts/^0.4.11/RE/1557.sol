contract ExposedInternalsForTesting is
  MoneyRounderMixin, NameableMixin {

    function roundMoneyDownNicelyET(uint _rawValueWei) constant
    returns (uint nicerValueWei) {
        return roundMoneyDownNicely(_rawValueWei);
    }

    function roundMoneyUpToWholeFinneyET(uint _valueWei) constant
    returns (uint valueFinney) {
        return roundMoneyUpToWholeFinney(_valueWei);
    }

    function validateNameInternalET(string _name) constant
    returns (bool allowed) {
        return validateNameInternal(_name);
    }

    function extractNameFromDataET(bytes _data) constant
    returns (string extractedName) {
        return extractNameFromData(_data);
    }
    
    function computeNameFuzzyHashET(string _name) constant
    returns (uint fuzzyHash) {
        return computeNameFuzzyHash(_name);
    }

}