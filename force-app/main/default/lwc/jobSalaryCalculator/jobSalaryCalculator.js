// compensationCalculator.js
import { LightningElement, track } from 'lwc';
import calculateCompensation from '@salesforce/apex/JobApplicationHelper.calculateCompensationAndTaxes';

export default class CompensationCalculator extends LightningElement {
    @track salary = 0;
    @track federalIncomeTax = 0;
    @track socialSecurityTax = 0;
    @track medicareWithholding = 0;
    @track netAnnualPay = 0;
    @track netMonthlyPay = 0;
    @track salaryBand = '';
    @track isCalculating = false;
    @track error = '';
    @track hasResults = false;

    handleSalaryChange(event) {
        try {
            this.salary = event.target.value;
            // Don't auto-clear results - let user see them until they calculate again
        } catch (error) {
            console.error('Error in handleSalaryChange:', error);
        }
    }

    async handleClick() {
        if (!this.salary || this.salary <= 0) {
            this.error = 'Please enter a valid salary amount';
            return;
        }

        this.isCalculating = true;
        this.error = '';
        
        try {
            const result = await calculateCompensation({ salary: parseFloat(this.salary) });
            
            if (result.success) {
                this.federalIncomeTax = result.federalIncomeTax || 0;
                this.socialSecurityTax = result.socialSecurityTax || 0;
                this.medicareWithholding = result.medicareWithholding || 0;
                this.netAnnualPay = result.netAnnualPay || 0;
                this.netMonthlyPay = result.netMonthlyPay || 0;
                this.salaryBand = result.salaryBand || '';
                this.hasResults = true;
            } else {
                this.error = result.error;
                this.clearResults();
            }
        } catch (error) {
            this.error = 'Error calculating compensation: ' + (error.body?.message || error.message);
            this.clearResults();
        } finally {
            this.isCalculating = false;
        }
    }

    clearResults() {
        try {
            this.federalIncomeTax = 0;
            this.socialSecurityTax = 0;
            this.medicareWithholding = 0;
            this.netAnnualPay = 0;
            this.netMonthlyPay = 0;
            this.salaryBand = '';
            this.hasResults = false;
            this.error = '';
        } catch (error) {
            console.error('Error in clearResults:', error);
        }
    }

    // Getters for formatted currency display
    get formattedFederalTax() {
        return this.formatCurrency(this.federalIncomeTax);
    }

    get formattedSocialSecurityTax() {
        return this.formatCurrency(this.socialSecurityTax);
    }

    get formattedMedicareWithholding() {
        return this.formatCurrency(this.medicareWithholding);
    }

    get formattedNetAnnualPay() {
        return this.formatCurrency(this.netAnnualPay);
    }

    get formattedNetMonthlyPay() {
        return this.formatCurrency(this.netMonthlyPay);
    }

    formatCurrency(amount) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }).format(amount || 0);
    }
}