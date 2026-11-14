import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/assistant_message.dart';
import '../../user/cubit/user_cubit.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  static const _suggestions = [
    'Explain my heart rate.',
    'How can I sleep better?',
    'When should I contact a flight surgeon?',
  ];

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late final AssistantMessage _welcomeMessage;
  final List<AssistantMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    final username = context.read<UserCubit>().state.username;
    _welcomeMessage = AssistantMessage(
      role: AssistantMessageRole.assistant,
      text:
          'Hi $username. I can explain your readings and suggest what to do next. What would you like to know?',
      createdAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? suggestedText]) {
    final text = (suggestedText ?? _controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        AssistantMessage(
          role: AssistantMessageRole.user,
          text: text,
          createdAt: DateTime.now(),
        ),
      );
      _controller.clear();
    });
    _scrollToLatest();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space20,
        vertical: AppDimensions.space12,
      ),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxBubbleWidth = (constraints.maxWidth * 0.72)
                    .clamp(220.0, 660.0)
                    .toDouble();
                return ListView.builder(
                  key: const ValueKey('assistantConversation'),
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                  itemCount: _messages.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _messageBubble(
                        _welcomeMessage,
                        maxBubbleWidth,
                        key: const ValueKey('assistantWelcome'),
                      );
                    }
                    if (index == 1) return _suggestionChips;
                    return _messageBubble(
                      _messages[index - 2],
                      maxBubbleWidth,
                      key: ValueKey('assistantMessage-${index - 2}'),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('assistantMessageInput'),
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _sendMessage(),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your question...',
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space16,
                      vertical: AppDimensions.space12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius12,
                      ),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius12,
                      ),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius12,
                      ),
                      borderSide: const BorderSide(color: AppColors.borderCyan),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              PrimaryButton(
                label: 'Send',
                onPressed: _controller.text.trim().isEmpty
                    ? null
                    : _sendMessage,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Guidance only, not a medical diagnosis.',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _suggestionChips {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.space4,
        top: AppDimensions.space4,
        bottom: AppDimensions.space12,
      ),
      child: Wrap(
        spacing: AppDimensions.space8,
        runSpacing: AppDimensions.space8,
        children: _suggestions.map((suggestion) {
          return ActionChip(
            key: ValueKey('suggestion-$suggestion'),
            label: Text(suggestion),
            onPressed: () => _sendMessage(suggestion),
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.borderCyan),
            labelStyle: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
            ),
            shape: const StadiumBorder(),
          );
        }).toList(),
      ),
    );
  }

  Widget _messageBubble(
    AssistantMessage message,
    double maxWidth, {
    required Key key,
  }) {
    final isUser = message.role == AssistantMessageRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            key: key,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            decoration: BoxDecoration(
              color: isUser ? AppColors.cyan : AppColors.surface,
              border: isUser ? null : Border.all(color: AppColors.borderCyan),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppDimensions.radius16),
                topRight: const Radius.circular(AppDimensions.radius16),
                bottomLeft: Radius.circular(
                  isUser ? AppDimensions.radius16 : 4,
                ),
                bottomRight: Radius.circular(
                  isUser ? 4 : AppDimensions.radius16,
                ),
              ),
            ),
            child: Text(
              message.text,
              style: AppTextStyles.body.copyWith(
                color: isUser ? AppColors.background : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
