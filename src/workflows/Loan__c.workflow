<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Loan</fullName>
        <description>New Loan</description>
        <protected>false</protected>
        <recipients>
            <recipient>Student</recipient>
            <type>role</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/newLoan</template>
    </alerts>
    <alerts>
        <fullName>loanExpired</fullName>
        <description>loanExpired</description>
        <protected>false</protected>
        <recipients>
            <recipient>Student</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/loanExpired</template>
    </alerts>
    <alerts>
        <fullName>oneDayLeft</fullName>
        <description>oneDayLeft</description>
        <protected>false</protected>
        <recipients>
            <recipient>Student</recipient>
            <type>role</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/previousDayEmailAlert</template>
    </alerts>
    <fieldUpdates>
        <fullName>auxUpdate</fullName>
        <field>availableAux__c</field>
        <literalValue>1</literalValue>
        <name>auxUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Copy_Loan__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>loanReopened</fullName>
        <field>Returned__c</field>
        <name>loanReopened</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>setAvailableTrue</fullName>
        <field>Available__c</field>
        <literalValue>1</literalValue>
        <name>setAvailableTrue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Copy_Loan__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>copyReturned</fullName>
        <actions>
            <name>setAvailableTrue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>!ISNULL(Returned__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>loanExpired</fullName>
        <actions>
            <name>loanExpired</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>TODAY() - Return_Date__c = 1</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Loan__c.Return_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>newLoanEmail</fullName>
        <actions>
            <name>New_Loan</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>oneDayLeft</fullName>
        <actions>
            <name>oneDayLeft</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>TODAY() - Return_Date__c = -1</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Loan__c.Return_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
