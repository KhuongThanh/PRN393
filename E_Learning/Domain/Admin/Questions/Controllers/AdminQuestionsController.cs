using E_Learning.Domain.Admin.Questions.Dtos;
using E_Learning.Domain.Admin.Questions.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace E_Learning.Domain.Admin.Questions.Controllers
{
    [ApiController]
    [Route("api/admin")]
    [Authorize(Roles = "Admin")]
    public class AdminQuestionsController : ControllerBase
    {
        private readonly IAdminQuestionService _questionService;

        public AdminQuestionsController(IAdminQuestionService questionService)
        {
            _questionService = questionService;
        }

        [HttpGet("quizzes/{quizId:guid}/questions")]
        public async Task<IActionResult> GetByQuiz(Guid quizId)
        {
            try
            {
                var result = await _questionService.GetByQuizAsync(quizId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpGet("questions/{questionId:guid}")]
        public async Task<IActionResult> GetById(Guid questionId)
        {
            try
            {
                var result = await _questionService.GetByIdAsync(questionId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpPost("quizzes/{quizId:guid}/questions")]
        public async Task<IActionResult> Create(Guid quizId, [FromBody] CreateQuestionRequest request)
        {
            try
            {
                var result = await _questionService.CreateAsync(quizId, request);
                return CreatedAtAction(nameof(GetById), new { questionId = result.QuestionId }, result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("questions/{questionId:guid}")]
        public async Task<IActionResult> Update(Guid questionId, [FromBody] UpdateQuestionRequest request)
        {
            try
            {
                var result = await _questionService.UpdateAsync(questionId, request);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("questions/{questionId:guid}")]
        public async Task<IActionResult> Delete(Guid questionId)
        {
            try
            {
                await _questionService.DeleteAsync(questionId);
                return Ok(new { message = "Question deleted successfully." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
