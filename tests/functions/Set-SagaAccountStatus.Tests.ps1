Describe "Set-SagaAccountStatus Unit Tests" -Tag "Unit" {
    BeforeAll {
        # Place here all things needed to prepare for the tests
    }
    AfterAll {
        # Here is where all the cleanup tasks go
    }
    
    InModuleScope -ModuleName shiftavenue.GraphAutomation {
        Describe "Ensuring unchanged command signature" {
            It "should have the expected parameter sets" {
            (Get-Command Set-SagaAccountStatus).ParameterSets.Name | Should -Be '__AllParameterSets'
            }
        }
    }
}