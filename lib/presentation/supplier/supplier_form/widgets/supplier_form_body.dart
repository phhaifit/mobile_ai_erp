import 'package:flutter/material.dart';
import 'package:validators/validators.dart' as v;
import 'form_field.dart';
import 'section_label.dart';

class SupplierFormBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController codeCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController taxCodeCtrl;
  final TextEditingController idCardCtrl;
  final TextEditingController bankNameCtrl;
  final TextEditingController bankAccountCtrl;
  final TextEditingController bankNoteCtrl;
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onSubmit;

  const SupplierFormBody({
    super.key,
    required this.formKey,
    required this.codeCtrl,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.addressCtrl,
    required this.taxCodeCtrl,
    required this.idCardCtrl,
    required this.bankNameCtrl,
    required this.bankAccountCtrl,
    required this.bankNoteCtrl,
    required this.isSaving,
    required this.isEditing,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionLabel('Basic Information'),
          const SizedBox(height: 12),
          SupplierFormField(
            controller: codeCtrl,
            label: 'Supplier Code',
            hint: 'e.g. SUP001',
            icon: Icons.tag_outlined,
            isRequired: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Supplier code is required';
              }
              if (v.isEmpty || v.length > 50) {
                return 'Code must be between 1-50 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          SupplierFormField(
            controller: nameCtrl,
            label: 'Supplier Name',
            hint: 'e.g. Alpha Trading Co.',
            icon: Icons.business_outlined,
            isRequired: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Supplier name is required';
              }
              if (v.isEmpty || v.length > 255) {
                return 'Name must be between 1-255 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SectionLabel('Contact Details'),
          const SizedBox(height: 12),
          SupplierFormField(
            controller: phoneCtrl,
            label: 'Phone Number',
            hint: 'e.g. 0901234567',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v != null && v.isNotEmpty) {
                if (v.length > 20) {
                  return 'Phone must not exceed 20 characters';
                }
                final cleaned = v.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(cleaned)) {
                  return 'Phone must be 7-15 digits (spaces, dashes allowed)';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          SupplierFormField(
            controller: emailCtrl,
            label: 'Email Address',
            hint: 'e.g. supplier@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!v.isEmail(value)) {
                  return 'Invalid email format (e.g., supplier@example.com)';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          SupplierFormField(
            controller: addressCtrl,
            label: 'Address',
            hint: 'Street, District, City',
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          SectionLabel('Tax & ID'),
          const SizedBox(height: 12),
          SupplierFormField(
            controller: taxCodeCtrl,
            label: 'Tax Code',
            hint: 'e.g. 0123456789',
            icon: Icons.receipt_outlined,
            validator: (v) {
              if (v != null && v.isNotEmpty && v.length > 20) {
                return 'Tax code must not exceed 20 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          SupplierFormField(
            controller: idCardCtrl,
            label: 'ID Card',
            hint: 'e.g. 012345678901',
            icon: Icons.card_membership_outlined,
            validator: (v) {
              if (v != null && v.isNotEmpty && v.length > 20) {
                return 'ID card must not exceed 20 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SectionLabel('Payment Information'),
          const SizedBox(height: 12),
          SupplierFormField(
            controller: bankNameCtrl,
            label: 'Bank Name',
            hint: 'e.g. Vietcombank',
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 12),
          SupplierFormField(
            controller: bankAccountCtrl,
            label: 'Bank Account',
            hint: 'e.g. 0123456789',
            icon: Icons.wallet_outlined,
          ),
          const SizedBox(height: 12),
          SupplierFormField(
            controller: bankNoteCtrl,
            label: 'Bank Note',
            hint: 'Additional bank information…',
            icon: Icons.notes_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: isSaving ? null : onSubmit,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                isEditing ? 'Update Supplier' : 'Create Supplier',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
