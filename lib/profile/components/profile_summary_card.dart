import 'package:flutter/material.dart';

class ProfileSummaryCard extends StatelessWidget {
  final String nomeUsuario;
  final String email;
  final String telefone;
  final VoidCallback onTap;
  const ProfileSummaryCard({
    super.key,
    required this.nomeUsuario,
    required this.email,
    required this.telefone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D8D1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF963333), width: 2),
                ),
                child: const CircleAvatar(
                  backgroundColor: Color(0xFFF0D9D2),
                  child: Icon(Icons.person, size: 30, color: Color(0xFF963333)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeUsuario == 'Amanda' ? 'Amanda Silva' : nomeUsuario,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: Color(0xFF963333),
                          size: 14,
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            email.isEmpty ? 'E-mail não informado' : email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE8D8D1)),
          ),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                color: Color(0xFF963333),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  telefone.isEmpty ? 'Telefone não informado' : telefone,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
