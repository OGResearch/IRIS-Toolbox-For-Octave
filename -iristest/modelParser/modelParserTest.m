function Tests = modelParserTest()
Tests = functiontests(localfunctions);
end


%**************************************************************************
function testQuotes(This) %#ok<*DEFNU>

m = model('testQuotes.model');

% Descriptions of variables.
actDescript = get(m, 'description');
expDescript = struct( ...
    'x', 'Variable x', ...
    'y', 'Variable y', ...
    'z', 'Variable z' ...
    );
verifyEqual(This, actDescript, expDescript);

% Equation labels.
actLabel = get(m,'label');
expLabel = { ...
    'Equation x', ...
    'Equation y', ...
    'Equation z', ...
    };
verifyEqual(This, actLabel, expLabel);

end % testQuotes()


%**************************************************************************
function testBracketsInQuotes(This)

m = model('testBracketsInQuotes.model');

% Descriptions of variables.
actDescript = get(m,'description');
expDescript = struct( ...
    'x','Variable x ([%])', ...
    'y','(Variable y)', ...
    'z','Variable z' ...
    );
verifyEqual(This,actDescript,expDescript);

% Equation labels.
actLabel = get(m,'label');
expLabel = { ...
    '[Equation x]((', ...
    '{Equation {y', ...
    'Equation} z}', ...
    };
verifyEqual(This,actLabel,expLabel);

end % testBracketsInQuotes()


%**************************************************************************
function testAssignments(This)

m = model('testAssignment.model');

% Values assigned to variables in model file.
actAssign = get(m,'sstate');
expAssign = struct( ...
    'x',(1 + 2) + 1i, ...
    'y',complex(3*normpdf(2,1,0.5),2), ...
    'z',[1,2,3]*[4,5,6]' ...
    );
verifyEqual(This,actAssign,expAssign);

end % testAssignments()